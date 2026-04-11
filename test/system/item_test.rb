require "application_system_test_case"

class ItemTest < ApplicationSystemTestCase
  test "users can see items" do
    given "the following items exist" do
      create_sample_items(count: 1)
    end

    given "the user visits the items page" do
      visit items_path
    end

    then_ "the user can see the items" do
      assert_current_path items_path, ignore_query: true
      assert_text "Sample Item 1"
    end
  end

  test "non-logged in users cannot add new items option" do
    given "the user visits the new item page" do
      visit new_item_path
    end

    then_ "the new item button is not visible" do
      assert_no_selector "a.btn.btn-primary", text: "New Item"
    end
  end

  test "logged in users can add new items option" do
    given "the user is logged in" do
      create_sample_users(count: 1)
      visit new_session_path
      login_user_as(email: "sample_user_0@link.cuhk.edu.hk", password: "password123")
      # Wait for the session cookie to be set before navigating away
      assert_text "Log out"
    end

    given "the following categories and communities exist" do
      create_sample_categories()
      create_sample_communities()
    end

    given "the user visits the new item page" do
      visit new_item_path
    end

    when_ "the user fills in the form and submits it" do
      fill_in "Title", with: "New Item"
      fill_in "Price", with: 100
      select "Books", from: "Category"
      select "Chung Chi College", from: "Community"
      select "Good", from: "Condition"
      select "Available", from: "Status"
      click_button "Create Item"
    end

    then_ "the user can see the new item" do
      assert_current_path item_path, ignore_query: true
      assert_text "New Item"
      assert_text "100"
      assert_text "Books"
      assert_text "Chung Chi College"
      assert_text "Good"
    end
  end
end
