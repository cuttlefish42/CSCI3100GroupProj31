require "test_helper"

class Offers::CounterRejectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
    @offer = offers(:one)

    # Pre-configure the fixture to be in a countered state for these tests
    @offer.update!(status: :countered, counter_price: 15.00)
  end

  test "buyer can reject counter-offer" do
    sign_in_as(@buyer)

    post item_offer_counter_rejection_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.rejected?
    assert_equal "Counter-offer rejected. You can make a new offer if you'd like.", flash[:notice]
  end

  test "seller cannot reject the counter-offer" do
    sign_in_as(@seller)

    post item_offer_counter_rejection_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.countered? # Status should not have changed
    assert_equal "Not authorized.", flash[:alert]
  end

  test "cannot reject if offer is not countered" do
    # Reset offer to pending
    @offer.update!(status: :pending)
    sign_in_as(@buyer)

    post item_offer_counter_rejection_path(@item, @offer)

    assert_redirected_to item_url(@item)
    assert @offer.reload.pending? # Status should not have changed
    assert_equal "You can only reject a counter-offer.", flash[:alert]
  end
end
