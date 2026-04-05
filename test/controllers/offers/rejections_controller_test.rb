require "test_helper"

class Offers::RejectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
  end

  test "seller can reject offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    post item_offer_rejection_path(@item, offer)

    assert_redirected_to item_url(@item)
    assert offer.reload.rejected?
  end

  test "non-seller cannot reject offer" do
    sign_in_as(@buyer)
    offer = offers(:one)

    post item_offer_rejection_path(@item, offer)

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
    assert_equal "Not authorized.", flash[:alert]
  end

  test "cannot reject non-pending offer" do
    sign_in_as(@seller)
    offer = offers(:one)
    offer.update!(status: :accepted)

    post item_offer_rejection_path(@item, offer)

    assert_redirected_to item_url(@item)
    assert_equal "This offer is no longer pending and cannot be modified.", flash[:alert]
  end
end
