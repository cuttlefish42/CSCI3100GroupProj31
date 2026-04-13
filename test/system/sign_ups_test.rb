require "application_system_test_case"

class SignUpsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "happy path: user signs up successfully" do
    given "communities exist" do
      create_sample_communities
    end

    when_ "the user fills in the form and submits" do
      visit sign_up_path
      fill_in "First name", with: "Jane"
      fill_in "Last name", with: "Doe"
      fill_in "Email address", with: "jane@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      select "Chung Chi College", from: "Default Community"

      perform_enqueued_jobs do
        click_button "Sign up"
        assert_text "Welcome"
      end
    end

    then_ "the user is signed in and a welcome email is sent" do
      assert_text "Log out"
      welcome = ActionMailer::Base.deliveries.find { |m| m.to.include?("jane@link.cuhk.edu.hk") }
      assert_not_nil welcome, "Expected a welcome email to jane@link.cuhk.edu.hk"
    end
  end

  test "sad path: mismatched password" do
    when_ "the user submits with mismatched passwords" do
      visit sign_up_path
      fill_in "First name", with: "Jane"
      fill_in "Last name", with: "Doe"
      fill_in "Email address", with: "jane@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "different"
      click_button "Sign up"
    end

    then_ "the user sees an error" do
      assert_text "Password confirmation doesn't match"
    end
  end

  test "sad path: duplicate email" do
    given "a user already exists" do
      create_sample_user(email_address: "taken@link.cuhk.edu.hk")
    end

    when_ "someone tries to sign up with the same email" do
      visit sign_up_path
      fill_in "First name", with: "New"
      fill_in "Last name", with: "Person"
      fill_in "Email address", with: "taken@link.cuhk.edu.hk"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      click_button "Sign up"
    end

    then_ "the user sees an error" do
      assert_text "Email address has already been taken"
    end
  end
end
