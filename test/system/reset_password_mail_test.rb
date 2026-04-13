require "application_system_test_case"

class PasswordResetFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @user = create_sample_user(email_address: "reset@link.cuhk.edu.hk")
    ActionMailer::Base.deliveries.clear
  end

  test "user resets their password via email link" do
    given "the user is on the forgot password page" do
      visit new_password_path
    end

    when_ "they submit their email address" do
      fill_in "Email", with: "reset@link.cuhk.edu.hk"
      perform_enqueued_jobs do
        click_button "Email reset instructions"
        assert_text "Password reset instructions sent"
      end
    end

    then_ "they receive an email with a reset link" do
      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail
      @reset_url = mail.body.encoded.match(/href="http:\/\/example\.com([^"]+)"/)[1]
    end

    when_ "they visit the reset link and set a new password" do
      Capybara.reset_sessions!
      visit @reset_url
      fill_in "New password", with: "newpassword456"
      fill_in "Confirm password", with: "newpassword456"
      click_button "Save"
    end

    then_ "their password is changed" do
      assert_text "Password has been reset"
    end
  end
end
