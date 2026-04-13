require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  include SetupHelper
  setup do
    # 1. Create the users
    @seller = create_sample_user(email_address: "seller_#{SecureRandom.hex(4)}@link.cuhk.edu.hk")
    @buyer = create_sample_user(email_address: "buyer_#{SecureRandom.hex(4)}@link.cuhk.edu.hk")
    @items = create_sample_items(count: 1, seller: @seller)
    @item = @items.first 
  end

  test "analytics tabs: showing tabs for seller items" do
    given "a seller with an item is logged in" do
      system_sign_in(@seller)
      visit dashboard_path
    end

    then_ "they see the analytics tab for their item" do
      assert_text "Item Analytics"
      assert_selector "input[aria-label='#{@item.title}']"
    end
  end

  test "empty state: showing 'no items' and 'no offers' messages" do
    given "a new user with no items is logged in" do
      @new_user = create_sample_user(email_address: "new_user@link.cuhk.edu.hk")
      system_sign_in(@new_user)
      visit dashboard_path
    end

    then_ "they see empty state messages" do
      assert_text "No items listed yet."
      assert_text "no pending actions"
    end
  end

  test "offer tables: showing received offers" do
    # Create an offer manually now that the item exists
    @offer = Offer.create!(
      item: @item,
      buyer: @buyer,
      price_offered: 50,
      status: :pending
    )

    given "a seller visits their dashboard" do
      system_sign_in(@seller)
      visit dashboard_path
    end

    then_ "they see the offer in the received table" do
      assert_text "Offers I've Received"
      assert_text @item.title
      assert_text @buyer.full_name
    end
  end
end