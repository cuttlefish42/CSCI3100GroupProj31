require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  setup do
    @user = create_sample_user(email_address: "forgetful@link.cuhk.edu.hk")
    clear_emails
  end

  test "requesting a password reset sends an email with a valid link" do
    given "I am on the login page and forgot my password" do
      visit new_session_path
      click_link "Forgot password?"
    end

    when_ "I submit my email address" do
      fill_in "Email address", with: @user.email_address
      assert_emails 1 do
        click_button "Send reset instructions"
      end
    end

    then_ "I receive a reset email" do
      mail = last_email
      assert_equal [@user.email_address], mail.to
      assert_match "Reset Your Password Now!", mail.subject
      
      # Extract the URL from the email body to test it
      @reset_link = mail.body.encoded.match(/href="([^"]+)"/)[1]
    end

    when_ "I visit the link from the email" do
      visit @reset_link
    end

    then_ "I can set a new password" do
      fill_in "New password", with: "brand-new-password-123"
      fill_in "Confirm new password", with: "brand-new-password-123"
      click_button "Update Password"
      
      assert_text "Password has been reset"
    end
  end
end