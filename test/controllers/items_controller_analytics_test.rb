require "test_helper"

class ItemsControllerAnalyticsTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
    @seller = users(:one)
  end

  test "seller can fetch analytics JSON" do
    sign_in_as @seller
    get analytics_item_path(@item), as: :json

    assert_response :success
    data = JSON.parse(response.body)
    assert_kind_of Array, data
    assert_equal 2, data.size
    assert data.first.key?("recorded_at")
    assert data.first.key?("views_count")
    assert data.first.key?("likes_count")
  end

  test "non-owner is redirected" do
    sign_in_as users(:two)
    get analytics_item_path(@item)

    assert_redirected_to items_path
  end

  test "unauthenticated user is redirected" do
    get analytics_item_path(@item)
    assert_redirected_to new_session_path
  end
end
