require "test_helper"

class Offers::AcceptancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
  end

  test "seller can accept offer" do
    sign_in_as(@seller)
    offer = offers(:one)
    @item.update!(status: :available)

    post item_offer_acceptance_path(@item, offer)

    assert_redirected_to item_url(@item)
    assert offer.reload.accepted?
    assert @item.reload.reserved?
  end

  test "non-seller cannot accept offer" do
    sign_in_as(@buyer)
    offer = offers(:one)

    post item_offer_acceptance_path(@item, offer)

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
  end
end
