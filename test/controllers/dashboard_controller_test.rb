require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "authenticated user can view dashboard" do
    sign_in_as users(:one)
    get dashboard_path
    assert_response :success
  end

  test "shows sent offers" do
    sign_in_as users(:two)
    get dashboard_path
    assert_response :success
  end

  test "shows received offers" do
    sign_in_as users(:one)
    get dashboard_path
    assert_response :success
  end
end
