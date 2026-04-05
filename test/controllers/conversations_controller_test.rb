require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @conversation = conversations(:one) # sender: one, receiver: two
  end

  # --- Authentication ---

  test "index requires authentication" do
    get conversations_url
    assert_redirected_to new_session_path
  end

  test "show requires authentication" do
    get conversation_url(@conversation)
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    post conversations_url, params: { receiver_id: @other_user.id }
    assert_redirected_to new_session_path
  end

  # --- Index ---

  test "authenticated user can list conversations" do
    sign_in_as(@user)
    get conversations_url
    assert_response :success
  end

  # --- Show ---

  test "participant can view conversation" do
    sign_in_as(@user)
    get conversation_url(@conversation)
    assert_response :success
  end

  test "non-participant cannot view conversation" do
    sign_in_as(users(:three))
    get conversation_url(@conversation)
    assert_redirected_to conversations_path
    assert_equal "You do not have permission to access this conversation.", flash[:alert]
  end

  test "show works without item_id param" do
    sign_in_as(@user)
    get conversation_url(@conversation)
    assert_response :success
  end

  test "show loads item when item_id param present" do
    sign_in_as(@user)
    get conversation_url(@conversation, item_id: items(:one).id)
    assert_response :success
  end

  # --- Create ---

  test "create finds existing conversation instead of duplicating" do
    sign_in_as(@user)
    assert_no_changes -> { Conversation.count } do
      post conversations_url, params: { receiver_id: @other_user.id }
    end
    assert_redirected_to conversation_path(@conversation)
  end

  test "create makes new conversation when none exists" do
    sign_in_as(@user)
    assert_changes -> { Conversation.count }, +1 do
      post conversations_url, params: { receiver_id: users(:three).id }
    end
    assert_response :redirect
  end

  test "create passes through item_id param" do
    sign_in_as(@user)
    post conversations_url, params: { receiver_id: @other_user.id, item_id: items(:one).id }
    assert_redirected_to conversation_path(@conversation, item_id: items(:one).id)
  end
end
