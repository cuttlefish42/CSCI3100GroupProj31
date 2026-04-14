require "application_system_test_case"

class OfferStatusFlowTest < ApplicationSystemTestCase
  setup do
    @seller = create_sample_user(
      email_address: "seller@link.cuhk.edu.hk",
      first_name: "Seller", last_name: "Wang", karma: 0
    )
    @buyer = create_sample_user(
      email_address: "buyer@link.cuhk.edu.hk",
      first_name: "Buyer", last_name: "Chen", karma: 0
    )
    @buyer2 = create_sample_user(
      email_address: "buyer2@link.cuhk.edu.hk",
      first_name: "Rival", last_name: "Lee", karma: 0
    )
    category = Category.first || Category.create!(name: "Books")
    @item = Item.create!(
      title: "Test Textbook", description: "test textbook", price: 100, condition: :good,
      status: :available, category: category, seller: @seller
    )
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def as(user, &block)
    using_session(user.email_address) do
      system_sign_in(user) unless page.has_text?("Log out", wait: 0)
      block.call
    end
  end

  def make_offer(price)
    visit new_item_offer_path(@item)
    find("#offer_price_offered").fill_in with: price
    click_button "Submit Offer"
    assert_text "Offer submitted"
  end

  # ---------------------------------------------------------------------------
  # Test 1: Happy path
  # ---------------------------------------------------------------------------
  test "happy path: offer, accept, review, completed" do
    given "a buyer makes an offer on the item" do
      as(@buyer) { make_offer(80) }
    end

    offer = Offer.last

    when_ "the seller accepts the offer" do
      as(@seller) do
        visit dashboard_path
        assert_text "Test Textbook"
        accept_confirm { click_button "Accept" }
        assert_text "Offer accepted"
      end
    end

    then_ "offer is accepted and item is reserved" do
      assert offer.reload.accepted?
      assert @item.reload.reserved?
    end

    then_ "both buyer and seller see the review button" do
      as(@seller) do
        visit dashboard_path
        assert_text "Accepted"
        assert_link "Leave a Review"
      end

      as(@buyer) do
        visit dashboard_path
        assert_link "Leave a Review"
      end
    end

    when_ "the buyer submits a positive review" do
      as(@buyer) do
        visit new_item_offer_review_path(@item, offer)
        assert_text "Rate"
        choose "+1 Karma"
        click_button "Submit Review"
        assert_text "karma updated"
      end
    end

    then_ "the offer is still accepted (waiting for seller review)" do
      assert offer.reload.accepted?
      assert @item.reload.reserved?
    end

    when_ "the seller submits a review of the buyer" do
      as(@seller) do
        visit new_item_offer_review_path(@item, offer)
        assert_text "Rate"
        choose "+1 Karma"
        click_button "Submit Review"
        assert_text "karma updated"
      end
    end

    then_ "the offer is completed, item is sold, and karma is updated" do
      assert offer.reload.completed?
      assert @item.reload.sold?
      assert_equal 1, @seller.reload.karma
      assert_equal 1, @buyer.reload.karma
    end

    then_ "both dashboards show no pending actions" do
      as(@buyer) do
        visit dashboard_path
        assert_text "No pending actions"
      end

      as(@seller) do
        visit dashboard_path
        assert_text "No pending actions"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Test 2: Counter-offer negotiation
  # ---------------------------------------------------------------------------
  test "counter-offer flow: offer, counter, accept counter, review" do
    given "a buyer makes an offer" do
      as(@buyer) { make_offer(60) }
    end

    offer = Offer.last

    when_ "the seller counters with a higher price" do
      as(@seller) do
        visit dashboard_path
        find("[name='counter_price']").fill_in with: 85
        click_button "Counter"
        assert_text "Counter-offer sent"
      end
    end

    then_ "the offer is countered with the new price" do
      offer.reload
      assert offer.countered?
      assert_equal 85.0, offer.counter_price.to_f
    end

    when_ "the buyer accepts the counter-offer" do
      as(@buyer) do
        visit dashboard_path
        accept_confirm { click_button "Accept Counter" }
        assert_text "accepted the counter-offer"
      end
    end

    then_ "the offer is accepted at the counter price and item is reserved" do
      offer.reload
      assert offer.accepted?
      assert_equal 85.0, offer.price_offered.to_f
      assert @item.reload.reserved?
    end

    when_ "both parties submit reviews" do
      as(@buyer) do
        visit new_item_offer_review_path(@item, offer)
        choose "+1 Karma"
        click_button "Submit Review"
      end
      as(@seller) do
        visit new_item_offer_review_path(@item, offer)
        choose "+1 Karma"
        click_button "Submit Review"
      end
    end

    then_ "the transaction is completed and item is sold" do
      assert offer.reload.completed?
      assert @item.reload.sold?
    end
  end

  # ---------------------------------------------------------------------------
  # Test 3: Rejection paths
  # ---------------------------------------------------------------------------
  test "rejected offers never reach review stage" do
    given "a buyer makes an offer and the seller rejects it" do
      as(@buyer) { make_offer(50) }

      as(@seller) do
        visit dashboard_path
        accept_confirm { click_button "Reject" }
        assert_text "Offer rejected"
      end
    end

    offer1 = Offer.last

    then_ "the offer is rejected" do
      assert offer1.reload.rejected?
    end

    given "the buyer makes another offer and the seller counters" do
      as(@buyer) { make_offer(55) }

      as(@seller) do
        visit dashboard_path
        find("[name='counter_price']").fill_in with: 90
        click_button "Counter"
      end
    end

    when_ "the buyer rejects the counter-offer" do
      as(@buyer) do
        visit dashboard_path
        accept_confirm { click_button "Reject Counter" }
      end
    end

    then_ "the item is still available and no one can review" do
      assert @item.reload.available?

      as(@buyer) do
        visit new_item_offer_review_path(@item, offer1)
        assert_text "cannot review"

        visit dashboard_path
        assert_text "No pending actions"
      end

      as(@seller) do
        visit dashboard_path
        assert_text "No pending actions"
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Test 4: Competing offers
  # ---------------------------------------------------------------------------
  test "competing offers: loser auto-rejected, only winner can review" do
    given "two buyers make offers on the same item" do
      as(@buyer) { make_offer(80) }
      as(@buyer2) { make_offer(70) }
    end

    offer_winner = Offer.find_by(buyer: @buyer, item: @item)
    offer_loser = Offer.find_by(buyer: @buyer2, item: @item)

    when_ "the seller accepts the first buyer's offer" do
      as(@seller) do
        visit dashboard_path
        within "tr", text: "Buyer Chen" do
          accept_confirm { click_button "Accept" }
        end
        assert_text "Offer accepted"
      end
    end

    then_ "the winner's offer is accepted and loser's is auto-rejected" do
      assert offer_winner.reload.accepted?
      assert offer_loser.reload.rejected?
      assert @item.reload.reserved?
    end

    then_ "the winner sees the review button" do
      as(@buyer) do
        visit dashboard_path
        assert_link "Leave a Review"
      end
    end

    then_ "the loser sees their rejected offer and cannot review" do
      as(@buyer2) do
        visit dashboard_path
        assert_text "No pending actions"
        assert_text "Rejected"

        visit new_item_offer_review_path(@item, offer_loser)
        assert_text "cannot review"
      end
    end

    when_ "both parties submit reviews" do
      as(@buyer) do
        visit new_item_offer_review_path(@item, offer_winner)
        choose "-1 Karma"
        click_button "Submit Review"
      end
      as(@seller) do
        visit new_item_offer_review_path(@item, offer_winner)
        choose "+1 Karma"
        click_button "Submit Review"
      end
    end

    then_ "the transaction is completed and item is sold" do
      assert offer_winner.reload.completed?
      assert @item.reload.sold?
      assert_equal(-1, @seller.reload.karma)
      assert_equal 1, @buyer.reload.karma
    end
  end
end
