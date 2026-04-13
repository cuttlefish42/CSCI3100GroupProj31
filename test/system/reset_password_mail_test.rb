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

    then_ "they receive an email with the 'Reset Password' link" do
      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail, "No email was sent!"
      
      # Extract the path part only (everything after the host)
      # This changes "http://example.com/passwords/token/edit" to "/passwords/token/edit"
      relative_url = mail.body.encoded.match(/href="http:\/\/example\.com([^"]+)"/)[1]
      
      puts "\n[DEBUG] Visiting Relative URL: #{relative_url}"
      visit relative_url # Capybara will now use the correct local Puma port!
    end

    when_ "they follow the link and set a new password" do
      visit @reset_url
      
      # Using IDs instead of Labels to avoid Capybara lookup issues
      fill_in "password", with: "NewSecurePass123!"
      fill_in "password_confirmation", with: "NewSecurePass123!"
      
      # Match your button text exactly as seen in your HTML: "Save"
      click_button "Save"
    end

    then_ "their password is changed" do
      # This usually redirects to the login page or home
      # If this fails, check what message appears after clicking 'Save'
      assert_text "Password has been reset" 
    end
  end
end