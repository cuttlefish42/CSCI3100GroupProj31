require "application_system_test_case"

class RegistrationFlowTest < ApplicationSystemTestCase
  test "new user receives a welcome email after signing up" do
    given "I am on the registration page" do
      visit new_registration_path # Adjust to your actual route
    end

    when_ "I submit the registration form with valid details" do
      fill_in "First name", with: "Bono"
      fill_in "Last name", with: "Vox"
      fill_in "Email address", with: "bono@link.cuhk.edu.hk"
      fill_in "Password", with: "pro-level-password"
      fill_in "Password confirmation", with: "pro-level-password"
      
      assert_emails 1 do
        click_button "Sign up"
      end
    end

    then_ "I should see a success message" do
      assert_text "Welcome! You have signed up successfully"
    end

    then_ "I receive a welcome email with the correct content" do
      mail = last_email
      assert_equal ["bono@link.cuhk.edu.hk"], mail.to
      assert_equal "Welcome to Group 31 platform!", mail.subject
      assert_match "Welcome, Bono Vox!", mail.body.encoded
      assert_match "Login to your account", mail.body.encoded
    end
  end
end