require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  setup do
    @seller = create_sample_user(email_address: "seller@example.com")
    @buyer = create_sample_user(email_address: "buyer@example.com")
    
    @item = Item.create!(
      title: "Vintage Camera",
      description: "Working condition",
      price: 100,
      seller: @seller,
      status: :available
    )
  end

  test "empty state: showing 'no items' and 'no offers' messages" do
    given "a seller with no items or offers is logged in" do
      # Create a fresh user with nothing
      empty_user = create_sample_user(email_address: "empty@example.com")
      login_as(empty_user)
      visit dashboard_path
    end

    then_ "they see the empty state messages" do
      assert_text "No items listed yet."
      assert_text "no pending actions"
      assert_text "You haven't made any offers yet."
      assert_text "You haven't received any offers yet."
    end
  end

  test "analytics tabs: showing tabs for seller items" do
    given "a seller with an item is logged in" do
      login_as(@seller)
      visit dashboard_path
    end

    then_ "they see the analytics tab for their item" do
      within "div[role='tablist']" do
        assert_selector "input[aria-label='#{@item.title}']"
        assert_selector "canvas[data-controller='item-analytics-chart']", visible: false
      end
    end
  end

  test "offer tables: showing received and sent offers" do
    # Set up data: Buyer makes an offer to Seller
    @offer = Offer.create!(
      item: @item,
      buyer: @buyer,
      price_offered: 90,
      status: :pending
    )

    given "a seller visits their dashboard" do
      login_as(@seller)
      visit dashboard_path
    end

    then_ "they see the offer in the 'Offers I've Received' table" do
      within "section", text: "Offers I've Received" do # Assuming you add <section> or just check text
        assert_text @item.title
        assert_text @buyer.full_name
        assert_text "Pending"
        assert_button "Accept"
        assert_button "Reject"
      end
    end

    when_ "the buyer visits their dashboard" do
      login_as(@buyer)
      visit dashboard_path
    end

    then_ "they see the offer in the 'Offers I've Made' table" do
      assert_text "Offers I've Made"
      within "tr#sent_offer_#{@offer.id}" do
        assert_text @item.title
        assert_text @seller.full_name
        assert_text "Pending"
        assert_button "Withdraw"
      end
    end
  end
end