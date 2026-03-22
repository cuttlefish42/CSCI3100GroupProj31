require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
  end

  test "create requires authentication" do
    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 5.00 } }
      assert_redirected_to new_session_path
    end
  end

  test "authenticated buyer can create offer" do
    sign_in_as(@buyer)
    # Clear existing pending offer from fixture
    @item.offers.where(buyer: @buyer).destroy_all

    assert_changes -> { Offer.count }, +1 do
      post item_offers_path(@item), params: { offer: { price_offered: 5.00 } }
    end

    assert_redirected_to item_url(@item)
  end

  test "seller cannot create offer on own item" do
    sign_in_as(@seller)

    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 5.00 } }
    end

    assert_redirected_to item_url(@item)
  end

  test "seller can accept offer" do
    sign_in_as(@seller)
    offer = offers(:one)
    @item.update!(status: :available)

    patch item_offer_path(@item, offer), params: { offer: { status: "accepted" } }

    assert_redirected_to item_url(@item)
    assert offer.reload.accepted?
    assert @item.reload.reserved?
  end

  test "seller can reject offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { status: "rejected" } }

    assert_redirected_to item_url(@item)
    assert offer.reload.rejected?
  end

  test "non-seller cannot accept offer" do
    sign_in_as(@buyer)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { status: "accepted" } }

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
  end

  test "buyer can withdraw own offer" do
    sign_in_as(@buyer)
    offer = offers(:one)

    assert_changes -> { Offer.count }, -1 do
      delete item_offer_path(@item, offer)
    end

    assert_redirected_to item_url(@item)
  end

  test "non-buyer cannot withdraw offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    assert_no_changes -> { Offer.count } do
      delete item_offer_path(@item, offer)
    end

    assert_redirected_to item_url(@item)
  end

  test "buyer can create offer with message" do
    sign_in_as(@buyer)
    @item.offers.where(buyer: @buyer).destroy_all

    post item_offers_path(@item), params: { offer: { price_offered: 5.00, message: "Is this negotiable?" } }

    assert_redirected_to item_url(@item)
    assert_equal "Is this negotiable?", Offer.last.message
  end

  test "seller can counter an offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { status: "countered", counter_price: "75.00" } }

    assert_redirected_to item_url(@item)
    assert offer.reload.countered?
    assert_equal 75.00, offer.counter_price.to_f
  end

  test "counter requires a valid price" do
    sign_in_as(@seller)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { status: "countered", counter_price: "" } }

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
  end

  test "cannot create offer with zero price" do
    sign_in_as(@buyer)
    @item.offers.where(buyer: @buyer).destroy_all

    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 0 } }
    end

    assert_redirected_to item_url(@item)
  end

  test "dashboard requires authentication" do
    get offers_dashboard_path
    assert_redirected_to new_session_path
  end

  test "authenticated user can view dashboard" do
    sign_in_as(@buyer)
    get offers_dashboard_path
    assert_response :success
  end
end
