require "application_system_test_case"

class RegistrationFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper # Must be at the class level

  test "user registers and receives a welcome email" do
    unique_email = "test_#{Time.now.to_i}@link.cuhk.edu.hk"

    given "a guest is on the registration page" do
      visit sign_up_path 
    end

    when_ "they fill out the registration form" do
      fill_in "First name", with: "New"
      fill_in "Last name", with: "Buyer"
      fill_in "Email", with: unique_email
      fill_in "Password", with: "P@ssword123!"
      fill_in "Password confirmation", with: "P@ssword123!"
      
      # Wrap the button click and the assertion
      perform_enqueued_jobs do
        click_button "Sign up"
        # This will wait for the redirect and check for the flash message
        assert_text "Welcome" 
      end
    end

    then_ "an email is sent to the new user" do
      assert_emails 1
      mail = ActionMailer::Base.deliveries.last
      assert_equal [unique_email], mail.to
    end
  end
end