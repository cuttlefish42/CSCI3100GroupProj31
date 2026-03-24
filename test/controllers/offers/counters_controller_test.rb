require "test_helper"

class Offers::CountersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
  end

  test "seller can counter an offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    post item_offer_counter_path(@item, offer), params: { counter_price: "75.00" }

    assert_redirected_to item_url(@item)
    assert offer.reload.countered?
    assert_equal 75.00, offer.counter_price.to_f
  end

  test "counter requires a valid price" do
    sign_in_as(@seller)
    offer = offers(:one)

    post item_offer_counter_path(@item, offer), params: { counter_price: "" }

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
  end
end
