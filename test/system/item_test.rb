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

  test "visiting an item shows updated view count" do
    given "an item exists and a user is logged in" do
      create_sample_items(count: 1)
      user = create_sample_user(email_address: "viewer@link.cuhk.edu.hk", first_name: "Viewer", last_name: "One")
      system_sign_in(user)
    end

    when_ "the user visits the item page" do
      @item = Item.find_by!(title: "Sample Item 1")
      visit item_path(@item)
    end

    then_ "the view count is displayed" do
      assert_text "1 views"
    end
  end

  test "logged in user can like and unlike an item" do
    given "an item exists and a user is logged in" do
      create_sample_items(count: 1)
      user = create_sample_user(email_address: "liker@link.cuhk.edu.hk", first_name: "Like", last_name: "User")
      system_sign_in(user)
    end

    given "the user visits the item page" do
      @item = Item.find_by!(title: "Sample Item 1")
      visit item_path(@item)
    end

    when_ "the user clicks the heart button" do
      find("turbo-frame[id^='like_item'] button").click
    end

    then_ "the like count increases to 1" do
      within("turbo-frame[id^='like_item']") do
        assert_text "1"
      end
    end

    when_ "the user clicks the heart button again" do
      find("turbo-frame[id^='like_item'] button").click
    end

    then_ "the like count goes back to 0" do
      within("turbo-frame[id^='like_item']") do
        assert_text "0"
      end
    end
  end

  test "logged in users can add new items option" do
    given "the user is logged in" do
      create_sample_users(count: 1)
      system_sign_in(User.find_by!(email_address: "sample_user_0@link.cuhk.edu.hk"))
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
      # Wait for the form submission and redirect to complete before querying
      # the DB, otherwise the test process may run ahead of the controller.
      assert_text "Item created"
      assert_text "New Item"
      assert_text "100"
      assert_text "Books"
      assert_text "Chung Chi College"
      assert_text "Good"

      seller = User.find_by!(email_address: "sample_user_0@link.cuhk.edu.hk")
      created_item = Item.find_by!(title: "New Item", seller: seller)
      assert_current_path item_path(created_item), ignore_query: true
    end
  end
end
