require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @conversation = conversations(:one) # sender: one, receiver: two
  end

  test "create requires authentication" do
    post conversation_messages_url(@conversation),
      params: { message: { content: "Hello" } }
    assert_redirected_to new_session_path
  end

  test "participant can send message" do
    sign_in_as(@user)
    assert_changes -> { @conversation.messages.count }, +1 do
      post conversation_messages_url(@conversation),
        params: { message: { content: "Hello" } }
    end
    assert_response :created
  end

  test "non-participant cannot send message" do
    sign_in_as(users(:three))
    assert_no_changes -> { @conversation.messages.count } do
      post conversation_messages_url(@conversation),
        params: { message: { content: "Hello" } }
    end
    assert_redirected_to conversations_path
  end

  test "message content is saved correctly" do
    sign_in_as(@user)
    post conversation_messages_url(@conversation),
      params: { message: { content: "Test message content" } }

    assert_equal "Test message content", @conversation.messages.last.content
    assert_equal @user, @conversation.messages.last.sender
  end

  test "message with item attachment saves correctly" do
    sign_in_as(@user)
    post conversation_messages_url(@conversation),
      params: { message: { content: "Check this out", item_id: items(:one).id } }

    assert_response :created
    assert_equal items(:one), @conversation.messages.last.item
  end

  test "receiver can also send message" do
    sign_in_as(users(:two))
    assert_changes -> { @conversation.messages.count }, +1 do
      post conversation_messages_url(@conversation),
        params: { message: { content: "Reply" } }
    end
    assert_response :created
    assert_equal users(:two), @conversation.messages.last.sender
  end
end
