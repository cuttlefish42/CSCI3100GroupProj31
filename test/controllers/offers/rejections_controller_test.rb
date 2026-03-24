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
end
