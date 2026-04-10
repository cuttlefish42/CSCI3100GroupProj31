require "application_system_test_case"

class AuthenticationFlowTest < ApplicationSystemTestCase
  test "user signs in with valid credentials" do
    given "an existing user" do
      create_sample_user
    end

    when_ "the user visits sign in and submits valid credentials" do
      visit new_session_path
      fill_in "Email", with: "sample_user_1@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      click_button "Sign in"
    end

    then_ "the user is redirected to the root items page" do
      assert_current_path root_path, ignore_query: true
    end
  end

  # invalid sign in attempts
  test "user tries to sign in with invalid email" do
    given "an existing user" do
      create_sample_user
    end

    when_ "the user visits sign in and submits the wrong email" do
      visit new_session_path
      fill_in "Email", with: "wrong_email@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      click_button "Sign in"
    end

    then_ "the user sees a warning message" do
      assert_current_path new_session_path, ignore_query: true
      assert_selector "div.alert"
    end
  end

  test "user tries to sign in with invalid password" do
    given "an existing user" do
      create_sample_user
    end

    when_ "the user visits sign in and submits the wrong password" do
      visit new_session_path
      fill_in "Email", with: "sample_user_1@link.cuhk.edu.hk"
      fill_in "Password", with: "wrongpassword123"
      click_button "Sign in"
    end

    then_ "the user sees a warning message" do
      assert_current_path new_session_path, ignore_query: true
      assert_selector "div.alert"
    end
  end
end
