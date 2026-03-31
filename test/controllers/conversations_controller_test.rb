require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @conversation = conversations(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get conversations_url
    assert_response :success
  end

  test "should get show" do
    get conversation_url(@conversation)
    assert_response :success
  end

  test "should create conversation" do
    post conversations_url, params: { receiver_id: users(:two).id }
    assert_response :redirect
  end
end
