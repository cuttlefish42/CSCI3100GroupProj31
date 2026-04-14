require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
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
    @category = Category.find_by!(name: "Books")
    @community = Community.find_by!(name: "Chung Chi College")
  end

  test "seller with no items sees empty dashboard" do
    given "the seller is logged in" do
      system_sign_in(@seller)
    end

    when_ "they visit the dashboard" do
      visit dashboard_path
    end

    then_ "they see empty states" do
      assert_text "Dashboard"
      assert_text "No items listed yet"
      assert_text "No pending actions"
    end
  end

  test "seller with items sees analytics tabs" do
    given "the seller has an item listed" do
      @item = Item.create!(
        title: "Smart Brain Book", description: "Very smart.", price: 50,
        seller: @seller, category: @category, community: @community,
        condition: :like_new, status: :available
      )
      system_sign_in(@seller)
    end

    when_ "they visit the dashboard" do
      visit dashboard_path
    end

    then_ "the analytics section shows a tab for their item" do
      assert_selector "input[aria-label='Smart Brain Book']"
    end
  end

  test "seller sees received offers with actions" do
    given "a buyer has made an offer on the seller's item" do
      @item = Item.create!(
        title: "Smart Brain Book", description: "Very smart.", price: 50,
        seller: @seller, category: @category, community: @community,
        condition: :like_new, status: :available
      )
      @offer = Offer.create!(
        item: @item, buyer: @buyer, price_offered: 45,
        message: "I want this book!", status: :pending
      )
      system_sign_in(@seller)
    end

    when_ "they visit the dashboard" do
      visit dashboard_path
    end

    then_ "they see the offer with accept/reject actions" do
      assert_text "Smart Brain Book"
      assert_text "Buyer Chen"
      assert_text "$45.00"
      assert_button "Accept"
      assert_button "Reject"
    end
  end

  test "buyer sees sent offers without accept/reject" do
    given "the buyer has made an offer" do
      @item = Item.create!(
        title: "Smart Brain Book", description: "Very smart.", price: 50,
        seller: @seller, category: @category, community: @community,
        condition: :like_new, status: :available
      )
      @offer = Offer.create!(
        item: @item, buyer: @buyer, price_offered: 45, status: :pending
      )
      system_sign_in(@buyer)
    end

    when_ "they visit the dashboard" do
      visit dashboard_path
    end

    then_ "they see their offer but cannot accept/reject" do
      assert_text "Smart Brain Book"
      assert_text "Pending"
      assert_button "Withdraw"
      assert_no_button "Accept"
      assert_no_button "Reject"
    end
  end
end
