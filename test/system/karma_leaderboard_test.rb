require "application_system_test_case"

class KarmaLeaderboardTest < ApplicationSystemTestCase
  # check that only top 20 users are shown
  test "at most 20 users are shown" do
    given "more than 20 users are in the database" do
      create_sample_users(count: 25)
    end

    given "the user is logged in" do
      visit new_session_path
      login_user_as(email: "sample_user_0@link.cuhk.edu.hk", password: "password123")
      # Wait for the session cookie to be set before navigating away
      assert_text "Log out"
    end

    when_ "the user is in karma leaderboard page" do
      visit karma_leaderboard_path
    end

    then_ "the user should see 20 entries" do
      assert_current_path karma_leaderboard_path, ignore_query: true
      rows = all("tbody tr").map(&:text)
      assert_equal 20, rows.length
    end
  end

  # check sort by descending order
  test "user checks karma leaderboard for lowest karma users" do
    given "the following sample users exists" do
      create_sample_users(count: 5)
    end

    given "the user is logged in" do
      visit new_session_path
      login_user_as(email: "sample_user_1@link.cuhk.edu.hk", password: "password123")
      assert_text "Log out"
    end

    when_ "the user visits karma leaderboard and clicks Highest Karma" do
      visit karma_leaderboard_path
      click_link "Highest Karma"
    end

    then_ "the user sees that leaderboard is sorted in descending order" do
      assert_current_path karma_leaderboard_path, ignore_query: true
      assert_selector "tbody tr"
      rows = all("tbody tr", minimum: 1).map(&:text)
      assert_operator rows.index { |row| row.include?("User4") }, :<, rows.index { |row| row.include?("User2") }
    end
  end

  # check sort by ascending order
  test "user checks karma leaderboard for highest karma users" do
    given "the following sample users exists" do
      create_sample_users(count: 5)
    end

    given "the user is logged in" do
      visit new_session_path
      login_user_as(email: "sample_user_1@link.cuhk.edu.hk", password: "password123")
      assert_text "Log out"
    end

    when_ "the user visits karma leaderboard and clicks Lowest Karma" do
      visit karma_leaderboard_path
      click_link "Lowest Karma"
    end

    then_ "the user sees that leaderboard is sorted in ascending order" do
      assert_current_path karma_leaderboard_path, ignore_query: true
      assert_selector "tbody tr"
      rows = all("tbody tr", minimum: 1).map(&:text)
      assert_operator rows.index { |row| row.include?("User1") }, :<, rows.index { |row| row.include?("User3") }
    end
  end
end
