require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  setup do
    @user = create_sample_user(email_address: "forgetful@link.cuhk.edu.hk")
    ActionMailer::Base.deliveries.clear
  end

  test "user resets their password via email link" do
    given "a registered user is on the forgot password page" do
      visit new_password_path 
    end

    when_ "they submit their email address to request a reset" do
      # Matches the label text "Email" from your view
      fill_in "Email", with: @user.email_address
      
      assert_emails 1 do
        # Matches the EXACT text from your form.submit helper
        click_button "Email reset instructions" 
      end
    end

    then_ "they receive an email with the 'Reset Password' link" do
      mail = ActionMailer::Base.deliveries.last
      assert_match "Reset Your Password Now!", mail.subject
      
      # This regex scrapes the link from the email body you shared earlier
      @reset_url = mail.body.encoded.match(/<a[^>]+href="([^"]+)"[^>]*>Reset Password<\/a>/)[1]
      assert @reset_url, "Could not find the 'Reset Password' link in the email body"
    end

    when_ "they follow the link and set a new password" do
      visit @reset_url
      
      # Make sure these labels match your app/views/passwords/edit.html.erb labels!
      fill_in "New password", with: "NewSecurePass123!"
      fill_in "Confirm new password", with: "NewSecurePass123!"
      click_button "Update password"
    end

    then_ "their password is changed and they can log in" do
      # Adjust this text to match your actual success message/notification
      assert_text "Password has been reset" 
      
      visit new_session_path
      login_user_as(email: @user.email_address, password: "NewSecurePass123!")
      assert_text "Log out"
    end
  end
end