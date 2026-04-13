require "application_system_test_case"

class LandingPageTest < ApplicationSystemTestCase
  test "happy path: unauthenticated user sees landing page" do
    given "items exist" do
      create_sample_items(count: 2)
    end

    when_ "a guest visits the root URL" do
      visit root_path
    end

    then_ "they see the hero section and featured items" do
      assert_text "CUHK Marketplace"
      assert_text "How It Works"
      assert_text "Recently Listed"
      assert_text "Sample Item 1"
    end
  end

  test "happy path: authenticated user is redirected to items" do
    given "a user is logged in" do
      create_sample_users(count: 1)
      system_sign_in(User.find_by!(email_address: "sample_user_0@link.cuhk.edu.hk"))
    end

    when_ "they visit the root URL" do
      visit root_path
    end

    then_ "they are redirected to the items page" do
      assert_current_path items_path, ignore_query: true
    end
  end
end
