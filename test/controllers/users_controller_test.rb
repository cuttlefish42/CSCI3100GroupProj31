require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get user_path(users(:one))
    assert_redirected_to new_session_path
  end

  test "authenticated user can view profile" do
    sign_in_as users(:one)
    get user_path(users(:two))
    assert_response :success
  end
end
