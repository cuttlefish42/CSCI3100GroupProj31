require "application_system_test_case"

class MessagingFromItemTest < ApplicationSystemTestCase
  include BddSteps
  
  def setup
    @buyer = User.create!(email: "buyer@example.com", password: "password", full_name: "Test Buyer")
    @seller = User.create!(email: "seller@example.com", password: "password", full_name: "Test Seller")
    @item = Item.create!(
      title: "Test Item",
      description: "A great item for sale",
      price: 99.99,
      user: @seller,
      status: "available"
    )
  end

  test "user can start conversation from item page and send message" do
    given "a buyer viewing an item page" do
      system_sign_in(@buyer)
      visit item_path(@item)
    end

    when "the buyer clicks the message button" do
      click_on "Message Seller"
    end

    then "a conversation is created and chat page opens" do
      assert_current_path conversation_path(Conversation.last)
      assert_text @item.title
      assert_text @seller.full_name
    end

    when "the buyer types and sends a message" do
      fill_in "message_content", with: "Hi, I'm interested in this item!"
      click_on "Send"
    end

    then "the message appears in the chat" do
      within "#messages" do
        assert_text "Hi, I'm interested in this item!"
        assert_text "You"
      end
    end

    and "the seller sees the message" do
      sign_out
      system_sign_in(@seller)
      visit conversation_path(Conversation.last)
      
      within "#messages" do
        assert_text "Hi, I'm interested in this item!"
        assert_text @buyer.full_name
      end
    end
  end

  test "user cannot send empty message" do
    given "a buyer in a conversation" do
      system_sign_in(@buyer)
      visit item_path(@item)
      click_on "Message Seller"
    end

    when "the buyer tries to send an empty message" do
      fill_in "message_content", with: ""
      click_on "Send"
    end

    then "the message is not sent" do
      assert_no_selector ".chat-bubble"
    end

    and "an error message is shown" do
      assert_text "Message cannot be empty"
    end

    when "the buyer tries to send only whitespace" do
      fill_in "message_content", with: "   "
      click_on "Send"
    end

    then "the whitespace message is also rejected" do
      assert_no_selector ".chat-bubble"
      assert_text "Message cannot be empty"
    end
  end

  test "conversation persists between sessions" do
    given "a conversation has started between buyer and seller" do
      system_sign_in(@buyer)
      visit item_path(@item)
      click_on "Message Seller"
      fill_in "message_content", with: "First message"
      click_on "Send"
      sign_out
    end

    when "the seller logs in and checks messages" do
      system_sign_in(@seller)
      visit conversations_path
    end

    then "the seller sees the conversation in their inbox" do
      assert_text @buyer.full_name
      assert_text "First message"
      assert_text @item.title
    end

    when "the seller clicks the conversation" do
      click_on @buyer.full_name
    end

    then "the seller can reply" do
      fill_in "message_content", with: "Thanks for your interest!"
      click_on "Send"
      
      within "#messages" do
        assert_text "Thanks for your interest!"
      end
    end
  end

  test "multiple users can message about same item" do
    @buyer2 = User.create!(email: "buyer2@example.com", password: "password", full_name: "Second Buyer")

    given "two buyers interested in the same item" do
      # First buyer starts conversation
      system_sign_in(@buyer)
      visit item_path(@item)
      click_on "Message Seller"
      fill_in "message_content", with: "Message from buyer 1"
      click_on "Send"
      sign_out
      
      # Second buyer starts conversation
      system_sign_in(@buyer2)
      visit item_path(@item)
      click_on "Message Seller"
      fill_in "message_content", with: "Message from buyer 2"
      click_on "Send"
      sign_out
    end

    when "the seller views their conversations" do
      system_sign_in(@seller)
      visit conversations_path
    end

    then "the seller sees two separate conversations" do
      assert_selector ".conversation-item", count: 2
      assert_text @buyer.full_name
      assert_text @buyer2.full_name
    end

    and "each conversation is independent" do
      click_on @buyer.full_name
      assert_text "Message from buyer 1"
      assert_no_text "Message from buyer 2"
      
      visit conversations_path
      click_on @buyer2.full_name
      assert_text "Message from buyer 2"
      assert_no_text "Message from buyer 1"
    end
  end
end