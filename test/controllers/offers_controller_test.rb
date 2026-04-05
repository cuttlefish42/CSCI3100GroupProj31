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

    test "cannot create offer with zero price" do
    sign_in_as(@buyer)
    @item.offers.where(buyer: @buyer).destroy_all

    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 0 } }
    end

    assert_redirected_to item_url(@item)
  end

  test "buyer can edit pending offer price" do
    sign_in_as(@buyer)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { price_offered: "25.00" } }

    assert_redirected_to item_url(@item)
    assert_equal 25.0, offer.reload.price_offered.to_f
  end

  test "dashboard requires authentication" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "authenticated user can view dashboard" do
    sign_in_as(@buyer)
    get dashboard_path
    assert_response :success
  end

  test "cannot create offer on unavailable item" do
    sign_in_as(@buyer)
    @item.offers.where(buyer: @buyer).destroy_all
    @item.update!(status: :reserved)

    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 5.00 } }
    end

    assert_redirected_to item_url(@item)
    assert_equal "This item is no longer available for offers.", flash[:alert]
  end

  test "duplicate offer updates existing instead of creating new" do
    sign_in_as(@buyer)
    offer = offers(:one) # existing pending offer from buyer on item

    assert_no_changes -> { Offer.count } do
      post item_offers_path(@item), params: { offer: { price_offered: 99.00 } }
    end

    assert_redirected_to item_url(@item)
    assert_equal 99.00, offer.reload.price_offered.to_f
  end

  test "non-buyer cannot edit offer" do
    sign_in_as(@seller)
    offer = offers(:one)

    patch item_offer_path(@item, offer), params: { offer: { price_offered: 99.00 } }

    assert_redirected_to item_url(@item)
    assert_equal "Not authorized.", flash[:alert]
    assert_equal 9.99, offer.reload.price_offered.to_f
  end

  test "cannot edit accepted offer" do
    sign_in_as(@buyer)
    offer = offers(:one)
    offer.update!(status: :accepted)

    patch item_offer_path(@item, offer), params: { offer: { price_offered: 99.00 } }

    assert_redirected_to item_url(@item)
    assert_equal "You can only edit pending or countered offers.", flash[:alert]
    assert_equal 9.99, offer.reload.price_offered.to_f
  end

  test "editing countered offer resets status to pending" do
    sign_in_as(@buyer)
    offer = offers(:one)
    offer.update!(status: :countered, counter_price: 50.00)

    patch item_offer_path(@item, offer), params: { offer: { price_offered: 30.00 } }

    assert_redirected_to item_url(@item)
    assert offer.reload.pending?
    assert_equal 30.00, offer.reload.price_offered.to_f
  end
end
