require "test_helper"

class Offers::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @buyer = users(:two)
    @seller = users(:one)
  end

  test "dashboard requires authentication" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "authenticated user can view dashboard" do
    sign_in_as(@buyer)
    get dashboard_path
    assert_response :success
  end
end
