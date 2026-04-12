require "application_system_test_case"

class UserMailerSystemTest < ApplicationSystemTestCase
  include BddSteps
  # ActionMailer::TestHelper is usually included in system tests by default in modern Rails,
  # but including it explicitly ensures access to `assert_emails`.
  include ActionMailer::TestHelper 

  setup do
    @seller = users(:one)
    @buyer = users(:two)
    @item = items(:one)
    
    # Ensure no leftover emails from previous tests
    ActionMailer::Base.deliveries.clear 
  end

  test "user requests a password reset email" do
    given "a user is on the forgot password page" do
      visit new_password_reset_path # Adjust to your actual route
    end

    when_ "they submit their email address" do
      assert_emails 1 do
        fill_in "Email address", with: @seller.email_address
        click_on "Send Reset Link"
        
        # Always assert a UI change in a system test before checking backend state
        # This forces Capybara to wait for the request to finish before moving on.
        assert_text "Password reset instructions have been sent" 
      end
    end

    then_ "they receive an email with a valid reset link" do
      mail = ActionMailer::Base.deliveries.last
      assert_equal [ @seller.email_address ], mail.to
      assert_equal "Reset Your Password Now!", mail.subject

      # Extract the URL from the email body and visit it to ensure it works
      body = mail.html_part ? mail.html_part.body.to_s : mail.body.to_s
      reset_url = body.match(/href="([^"]+)"/)[1]
      
      visit reset_url
      assert_selector "h1", text: "Reset Password" # Adjust based on your UI
    end
  end

  test "buyer makes an offer and triggers an email to the seller" do
    given "a logged-in buyer visits the seller's item page" do
      # Assuming you have a test helper to log in users
      login_as(@buyer) 
      visit item_path(@item)
    end

    when_ "the buyer submits a new offer" do
      assert_emails 1 do
        fill_in "Price offered", with: 50.00 # Adjust field name to match your form label
        click_on "Submit Offer"
        
        # Wait for the UI confirmation to ensure the controller action completes
        assert_text "Offer successfully submitted" 
      end
    end

    then_ "the seller receives a notification with a link to the offer" do
      mail = ActionMailer::Base.deliveries.last
      
      assert_equal [ @seller.email_address ], mail.to
      assert_equal "New offer for #{@item.title}", mail.subject
      
      # Verify the email body contains the new offer amount
      body = mail.html_part ? mail.html_part.body.to_s : mail.body.to_s
      assert_includes body, "50.0"
    end
  end
end
