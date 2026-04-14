require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @offer = offers(:one)
    @seller = users(:one)
    @buyer = users(:two)
    # Offer must be accepted for reviews
    @offer.update_columns(status: :accepted)
  end

  test "new requires authentication" do
    get new_item_offer_review_path(@item, @offer)
    assert_redirected_to new_session_path
  end

  test "buyer can access new review form" do
    sign_in_as @buyer
    get new_item_offer_review_path(@item, @offer)
    assert_response :success
  end

  test "seller can access new review form" do
    sign_in_as @seller
    get new_item_offer_review_path(@item, @offer)
    assert_response :success
  end

  test "uninvolved user cannot review" do
    sign_in_as users(:three)
    get new_item_offer_review_path(@item, @offer)
    assert_redirected_to dashboard_path
  end

  test "buyer can create review" do
    sign_in_as @buyer
    assert_difference "Review.count", 1 do
      post item_offer_review_path(@item, @offer), params: {
        review: { rating: 1, comment: "Great seller!" }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "seller can create review" do
    sign_in_as @seller
    assert_difference "Review.count", 1 do
      post item_offer_review_path(@item, @offer), params: {
        review: { rating: -1, comment: "Difficult buyer" }
      }
    end
    assert_redirected_to dashboard_path
  end

  test "offer not completed after only buyer review" do
    sign_in_as @buyer
    post item_offer_review_path(@item, @offer), params: {
      review: { rating: 1, comment: "Great seller!" }
    }
    assert @offer.reload.accepted?, "Offer should still be accepted after one review"
  end

  test "offer completed after both reviews" do
    # Buyer reviews seller
    Review.create!(offer: @offer, reviewer: @buyer, reviewee: @seller,
                   role: :seller_review, rating: 1, comment: "Great")

    # Seller reviews buyer
    sign_in_as @seller
    post item_offer_review_path(@item, @offer), params: {
      review: { rating: 1, comment: "Good buyer" }
    }

    assert @offer.reload.completed?, "Offer should be completed after both reviews"
    assert @item.reload.sold?, "Item should be sold after both reviews"
  end

  test "prevents duplicate review" do
    sign_in_as @buyer
    Review.create!(
      offer: @offer, reviewer: @buyer, reviewee: @seller,
      role: :seller_review, rating: 1, comment: "Already reviewed"
    )

    get new_item_offer_review_path(@item, @offer)
    assert_redirected_to dashboard_path
  end
end
