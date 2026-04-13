require "application_system_test_case"

class MessagingFromItemTest < ApplicationSystemTestCase
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

  test "happy path: user sees conversations in inbox" do
    given "a conversation exists" do
      conversation = Conversation.find_or_create_between(@buyer, @seller)
      conversation.messages.create!(sender: @buyer, content: "Hello there")
      system_sign_in(@buyer)
    end

    when_ "they visit the inbox" do
      visit conversations_path
    end

    then_ "they see the conversation" do
      assert_text @seller.full_name
    end
  end

  test "buyer can start a conversation from item page and send a message" do
    given "the buyer is logged in and viewing the item" do
      system_sign_in(@buyer)
      visit item_path(@item)
    end

    when_ "the buyer clicks Chat" do
      click_button "Chat"
    end

    then_ "a conversation page opens" do
      assert_text @seller.full_name
    end

    when_ "the buyer sends a message" do
      fill_in "Type a message...", with: "Hi, is this still available?"
      click_button "Send"
    end

    then_ "the message appears in the chat" do
      within "#messages" do
        assert_text "Hi, is this still available?"
      end
    end
  end
end
