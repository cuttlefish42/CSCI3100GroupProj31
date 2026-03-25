require "test_helper"

class Offers::CounterAcceptancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
    @offer = offers(:one)

    # Pre-configure the fixture to be in a countered state for these tests
    @offer.update!(status: :countered, counter_price: 15.00)
    @item.update!(status: :available)
  end

  test "buyer can accept counter-offer" do
    sign_in_as(@buyer)

    post item_offer_counter_acceptance_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.accepted?

    # The price_offered should now equal the counter_price
    assert_equal 15.00, @offer.price_offered.to_f

    # The item should be reserved
    assert @item.reload.reserved?
  end

  test "seller cannot accept their own counter-offer" do
    sign_in_as(@seller)

    post item_offer_counter_acceptance_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.countered? # Status should not have changed
  end

  test "cannot accept if offer is not countered" do
    # Reset offer to pending
    @offer.update!(status: :pending)
    sign_in_as(@buyer)

    post item_offer_counter_acceptance_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.pending? # Status should not have changed
    assert_equal "You can only accept a counter-offer.", flash[:alert]
  end
end
