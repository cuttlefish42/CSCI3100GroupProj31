require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get show" do
    get item_url(items(:one))
    assert_response :success
  end
end
