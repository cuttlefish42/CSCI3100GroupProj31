require "application_system_test_case"

class AuthenticationFlowTest < ApplicationSystemTestCase
  test "user signs in with valid credentials" do
    given "an existing user" do
      create_sample_users(count: 1)
    end

    when_ "the user visits sign in and submits valid credentials" do
      visit new_session_path
      login_user_as(email: "sample_user_0@link.cuhk.edu.hk", password: "password123")
    end

    then_ "the user is redirected to the items page" do
      assert_current_path items_path, ignore_query: true
    end
  end

  # invalid sign in attempts
  test "user tries to sign in with invalid email" do
    given "an existing user" do
      create_sample_users(count: 1)
    end

    when_ "the user visits sign in and submits the wrong email" do
      visit new_session_path
      login_user_as(email: "wrong_email@link.cuhk.edu.hk", password: "password123")
    end

    then_ "the user sees a warning message" do
      assert_current_path new_session_path, ignore_query: true
      assert_selector "div.alert"
    end
  end

  test "user tries to sign in with invalid password" do
    given "an existing user" do
      create_sample_users(count: 1)
    end

    when_ "the user visits sign in and submits the wrong password" do
      visit new_session_path
      login_user_as(email: "sample_user_0@link.cuhk.edu.hk", password: "wrongpassword123")
    end

    then_ "the user sees a warning message" do
      assert_current_path new_session_path, ignore_query: true
      assert_selector "div.alert"
    end
  end
end
