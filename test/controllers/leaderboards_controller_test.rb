require "test_helper"

class LeaderboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "karma page loads" do
    get karma_leaderboard_path
    assert_response :success
  end

  test "karma page with highest sort" do
    get karma_leaderboard_path, params: { sort: "highest" }
    assert_response :success
  end

  test "karma page with lowest sort" do
    get karma_leaderboard_path, params: { sort: "lowest" }
    assert_response :success
  end
end
