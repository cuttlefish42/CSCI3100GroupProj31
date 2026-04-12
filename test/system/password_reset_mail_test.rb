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
      fill_in "Email", with: @user.email_address
      
      perform_enqueued_jobs do
        click_button "Email reset instructions"
      end
    end

    then_ "I receive a reset email" do
      assert_equal 1, ActionMailer::Base.deliveries.count, "Expected 1 email to be sent"
      
      # Verify email sender and contents
      mail = last_email
      assert_equal [@user.email_address], mail.to
      assert_match "password", mail.subject.downcase
      assert_match "reset", mail.body.encoded.downcase
    end

    then_ "I can use the reset link to set a new password" do
      # Extract reset link from email
      mail = last_email
      reset_url = mail.body.encoded.match(%r{/passwords/[\w-]+/edit})[0]
      
      visit reset_url
      
      fill_in "New password", with: "brand-new-password-123"
      fill_in "Confirm new password", with: "brand-new-password-123"
      click_button "Update Password"
      assert_text "Password has been reset"
    end
  end
end