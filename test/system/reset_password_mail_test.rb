require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper 

  setup do
    # Use a unique email to ensure no overlap with previous test runs
    @email = "forgetful_#{Time.now.to_i}@link.cuhk.edu.hk"
    @user = create_sample_user(email_address: @email)
    ActionMailer::Base.deliveries.clear
  end

  test "user resets their password via email link" do
    given "a registered user is on the forgot password page" do
      visit new_password_path 
    end

    when_ "they submit their email address to request a reset" do
      fill_in "Email", with: @email
      
      perform_enqueued_jobs do
        click_button "Email reset instructions" 
        
        # 1. WAIT for the success message on the UI. 
        # Check what your app says: e.g., "Check your email" or "Instructions sent"
        assert_text "Password reset instructions sent" 
      end
    end

    then_ "the mailbox should have the email" do
      # 2. Now that the page loaded, check the deliveries array
      assert_emails 1
      
      mail = ActionMailer::Base.deliveries.last
      assert_match "Reset Your Password Now!", mail.subject
      
      # Extract the URL
      @reset_url = mail.body.encoded.match(/<a[^>]+href="([^"]+)"[^>]*>Reset Password<\/a>/)[1]
    end

    when_ "they follow the link and set a new password" do
      visit @reset_url
      fill_in "New password", with: "NewSecurePass123!"
      fill_in "Confirm new password", with: "NewSecurePass123!"
      click_button "Update password"
    end

    then_ "their password is changed" do
      assert_text "Password has been reset" 
    end
  end
end