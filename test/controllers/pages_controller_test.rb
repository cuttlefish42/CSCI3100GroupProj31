require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "landing page loads for unauthenticated users" do
    get root_url
    assert_response :success
  end

  test "authenticated users are redirected to items" do
    sign_in_as users(:one)
    get root_url
    assert_redirected_to items_path
  end
end
