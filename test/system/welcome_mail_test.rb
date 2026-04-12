require "application_system_test_case"

class RegistrationFlowTest < ApplicationSystemTestCase
  setup do
    clear_emails
  end

  test "new user receives a welcome email after signing up" do
    given "I am on the registration page" do
      visit sign_up_path
    end

    when_ "I submit the registration form with valid details" do
      fill_in "First name", with: "Bono"
      fill_in "Last name", with: "Vox"
      fill_in "Email address", with: "bono@link.cuhk.edu.hk"
      fill_in "Password", with: "pro-level-password"
      fill_in "Password confirmation", with: "pro-level-password"
      
      click_button "Sign up"
    end

    then_ "I should see a success message" do
      assert_text "Welcome! Please check your email for confirmation."
    end

    then_ "I receive a welcome email with the correct content" do
      assert_equal 1, ActionMailer::Base.deliveries.count, "Expected 1 email to be sent"
      
      mail = last_email
      assert_equal ["bono@link.cuhk.edu.hk"], mail.to
      assert_equal "Welcome to Group 31 platform!", mail.subject
      assert_match "Welcome, Bono Vox!", mail.body.encoded
      assert_match "Login to your account", mail.body.encoded
    end
  end
end