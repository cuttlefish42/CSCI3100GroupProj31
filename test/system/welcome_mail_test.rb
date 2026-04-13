require "application_system_test_case"

class WelcomeMailFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "user registers and receives a welcome email" do
    given "communities exist" do
      create_sample_communities
    end

    when_ "a guest fills out the registration form" do
      visit sign_up_path
      fill_in "First name", with: "New"
      fill_in "Last name", with: "Buyer"
      fill_in "Email address", with: "newbuyer@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"

      perform_enqueued_jobs do
        click_button "Sign up"
        assert_text "Welcome"
      end
    end

    then_ "a welcome email is sent" do
      welcome = ActionMailer::Base.deliveries.find { |m| m.to.include?("newbuyer@link.cuhk.edu.hk") }
      assert_not_nil welcome, "Expected a welcome email to newbuyer@link.cuhk.edu.hk"
    end
  end
end
