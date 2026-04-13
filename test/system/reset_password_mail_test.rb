require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper 

  setup do
    # Use a unique, lowercase email every time
    @email = "user_#{SecureRandom.hex(4)}@link.cuhk.edu.hk".downcase
    @user = User.create!(
      first_name: "Test",
      last_name: "User",
      email_address: @email,
      password: "P@ssword123!",
      password_confirmation: "P@ssword123!"
    )
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
        # This WAIT is the most important part!
        # It ensures the server finishes before we check the mailbox.
        assert_text "Password reset instructions sent" 
      end
    end

    then_ "they receive an email with the link" do
      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail, "Mailer was never called! Check if User.find_by(email_address: '#{@email}') works."
      
      # Use a robust regex to get the path
      @reset_url = mail.body.encoded.match(/href="http:\/\/example\.com([^"]+)"/)[1]
      
      # Clear session to ensure we are a 'guest' when clicking the link
      Capybara.reset_sessions!
      visit @reset_url
    end

    when_ "they set a new password" do
      # Use placeholders from your HTML to be 100% sure
      fill_in "Enter new password", with: "NewSecurePass123!"
      fill_in "Repeat new password", with: "NewSecurePass123!"
      click_button "Save"
    end

    then_ "their password is changed" do
      assert_text "Password has been reset" 
    end
  end
end