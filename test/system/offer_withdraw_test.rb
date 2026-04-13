require "application_system_test_case"

class OfferWithdrawTest < ApplicationSystemTestCase
  setup do
    create_sample_communities
    create_sample_categories

    @seller = create_sample_user(
      email_address: "seller@link.cuhk.edu.hk",
      first_name: "Seller", last_name: "Wang"
    )
    @buyer = create_sample_user(
      email_address: "buyer@link.cuhk.edu.hk",
      first_name: "Buyer", last_name: "Chen"
    )
    category = Category.find_by!(name: "Books")
    community = Community.find_by!(name: "Chung Chi College")
    @item = Item.create!(
      title: "Test Textbook", description: "A test item", price: 100,
      condition: :good, status: :available,
      category: category, community: community, seller: @seller
    )
  end

  test "happy path: buyer withdraws a pending offer" do
    given "the buyer has made an offer" do
      Offer.create!(item: @item, buyer: @buyer, price_offered: 80, status: :pending)
      system_sign_in(@buyer)
    end

    when_ "they visit the dashboard and click Withdraw" do
      visit dashboard_path
      accept_confirm { click_button "Withdraw" }
    end

    then_ "the offer is withdrawn" do
      assert_text "Offer withdrawn"
    end
  end

  test "happy path: buyer re-submits offer on same item updates existing offer" do
    given "the buyer already has a pending offer" do
      Offer.create!(item: @item, buyer: @buyer, price_offered: 80, status: :pending)
      system_sign_in(@buyer)
    end

    when_ "they submit a new offer on the same item" do
      visit new_item_offer_path(@item)
      find("#offer_price_offered").fill_in with: 90
      click_button "Submit Offer"
    end

    then_ "the existing offer is updated" do
      assert_text "Offer updated"
      assert_equal 1, @item.offers.where(buyer: @buyer).count
      assert_equal 90, @item.offers.find_by(buyer: @buyer).price_offered.to_i
    end
  end

  test "sad path: buyer cannot offer on unavailable item" do
    given "the item is sold" do
      @item.update!(status: :sold)
      system_sign_in(@buyer)
    end

    when_ "they try to make an offer" do
      visit new_item_offer_path(@item)
    end

    then_ "they see the item is unavailable" do
      # The offer form submits but controller rejects it
      find("#offer_price_offered").fill_in with: 50
      click_button "Submit Offer"
      assert_text "no longer available"
    end
  end
end
