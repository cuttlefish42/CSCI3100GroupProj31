require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  setup do
    @user = create_sample_user(email_address: "forgetful@link.cuhk.edu.hk")
    ActionMailer::Base.deliveries.clear
  end

  test "user resets their password via email link" do
    given "a registered user requests a password reset" do
      visit new_password_reset_path # Adjust this to your 'forgot password' route
    end

    when_ "they submit their email address" do
      fill_in "Email", with: @user.email_address
      
      assert_emails 1 do
        click_button "Reset Password"
      end
    end

    then_ "they receive an email with a reset link" do
      mail = ActionMailer::Base.deliveries.last
      
      assert_equal [@user.email_address], mail.to
      assert_equal "Reset Your Password Now!", mail.subject
      
      # Extract the reset URL from the email's HTML body using Regex
      @reset_link = mail.body.encoded.match(/href="([^"]+)"/)[1]
      assert @reset_link, "Reset link not found in email body"
    end

    when_ "they click the link in the email and submit a new password" do
      # Capybara navigates to the extracted URL
      visit @reset_link
      
      fill_in "New Password", with: "new_secure_password_456"
      fill_in "Confirm Password", with: "new_secure_password_456"
      click_button "Update Password"
    end

    then_ "they can log in with the new password" do
      visit new_session_path
      login_user_as(email: @user.email_address, password: "new_secure_password_456")
      assert_text "Log out" # Verifies successful sign in
    end
  end
end