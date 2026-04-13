require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  # This line is REQUIRED to use perform_enqueued_jobs
  include ActiveJob::TestHelper 

  setup do
    @user = create_sample_user(email_address: "forgetful@link.cuhk.edu.hk")
    ActionMailer::Base.deliveries.clear
  end

  test "user resets their password via email link" do
    given "a registered user is on the forgot password page" do
      visit new_password_path 
    end

    when_ "they submit their email address to request a reset" do
      fill_in "Email", with: @user.email_address
      
      # This captures emails even if they are sent in the background
      perform_enqueued_jobs do
        assert_emails 1 do
          click_button "Email reset instructions" 
        end
      end
    end

    then_ "they receive an email with the 'Reset Password' link" do
      mail = ActionMailer::Base.deliveries.last
      assert_match "Reset Your Password Now!", mail.subject
      
      # Regex to find the URL in your HTML email
      @reset_url = mail.body.encoded.match(/<a[^>]+href="([^"]+)"[^>]*>Reset Password<\/a>/)[1]
      assert @reset_url, "Could not find the 'Reset Password' link in the email body"
    end

    when_ "they follow the link and set a new password" do
      # Note: Use the full URL from the email
      visit @reset_url
      
      # Double-check these labels in your edit.html.erb
      fill_in "New password", with: "NewSecurePass123!"
      fill_in "Confirm new password", with: "NewSecurePass123!"
      click_button "Update password"
    end

    then_ "their password is changed and they can log in" do
      # Verify the success message on the screen
      assert_text "Password has been reset" 
      
      visit new_session_path
      login_user_as(email: @user.email_address, password: "NewSecurePass123!")
      assert_text "Log out"
    end
  end
end