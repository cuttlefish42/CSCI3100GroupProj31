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
    # 1. FORCE LOGOUT (if your helper supports it)
    # Or just visit a path that clears session
    # visit logout_path 

    given "a registered user is on the forgot password page" do
      visit new_password_path 
    end

    when_ "they submit their email address" do
      fill_in "Email", with: @user.email_address
      perform_enqueued_jobs { click_button "Email reset instructions" }
    end

    then_ "they follow the link in the email" do
      mail = ActionMailer::Base.deliveries.last
      # Use the absolute URL since it's working now, or stick to relative
      @reset_url = mail.body.encoded.match(/href="http:\/\/example\.com([^"]+)"/)[1]
      
      # 2. LOG OUT BEFORE VISITING THE LINK
      # This ensures the 'token' is the only thing Rails cares about
      Capybara.reset_sessions! 
      
      visit @reset_url
    end

    when_ "they set a new password" do
      # Since you're on the right page now, placeholders or IDs will work
      fill_in "Enter new password", with: "NewSecurePass123!"
      fill_in "Repeat new password", with: "NewSecurePass123!"
      click_button "Save"
    end

    then_ "their password is changed" do
      # This usually redirects to the login page or home
      # If this fails, check what message appears after clicking 'Save'
      assert_text "Password has been reset" 
    end
  end
end