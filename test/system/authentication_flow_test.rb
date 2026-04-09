require "application_system_test_case"

class AuthenticationFlowTest < ApplicationSystemTestCase
  test "user signs in with valid credentials" do
    given "an existing user" do
      User.create!(
        email: "bdd_user@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    when_ "the user visits sign in and submits valid credentials" do
      visit new_session_path
      fill_in "Email", with: "bdd_user@example.com"
      fill_in "Password", with: "password123"
      click_button "Log in"
    end

    then_ "the user sees a successful sign-in state" do
      assert_text "Welcome"
    end
  end
end
