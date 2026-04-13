require "application_system_test_case"

class RegistrationFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper # Class level inclusion

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "user registers and receives a welcome email" do
    # Use a random email to avoid "Email already taken" errors
    test_email = "buyer_#{SecureRandom.hex(4)}@link.cuhk.edu.hk"

    given "a guest is on the registration page" do
      visit sign_up_path 
    end

    when_ "they fill out the registration form" do
      fill_in "First name", with: "New"
      fill_in "Last name", with: "Buyer"
      fill_in "Email", with: test_email
      fill_in "Password", with: "Password123!"
      fill_in "Password confirmation", with: "Password123!"
      
      perform_enqueued_jobs do
        assert_emails 1 do
          click_button "Sign up"
          
          # DEBUG: If the email count is still 0, this will print the error on the page
          if ActionMailer::Base.deliveries.empty?
            puts "\n[DEBUG] Validation Errors Found: " + page.text if page.has_css?('.error')
          end
        end
      end
    end

    then_ "they receive a welcome email" do
      mail = ActionMailer::Base.deliveries.last
      assert_not_nil mail, "Mailer was never triggered. Check for validation errors."
      assert_equal [test_email], mail.to
    end
  end
end