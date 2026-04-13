require "application_system_test_case"

class ItemManagementTest < ApplicationSystemTestCase
  setup do
    create_sample_communities
    create_sample_categories

    @seller = create_sample_user(
      email_address: "seller@link.cuhk.edu.hk",
      first_name: "Seller", last_name: "Wang"
    )
    @other_user = create_sample_user(
      email_address: "other@link.cuhk.edu.hk",
      first_name: "Other", last_name: "User"
    )
    category = Category.find_by!(name: "Books")
    community = Community.find_by!(name: "Chung Chi College")
    @item = Item.create!(
      title: "Old Textbook", description: "Needs updating", price: 100,
      condition: :good, status: :available,
      category: category, community: community, seller: @seller
    )
  end

  test "happy path: seller edits their item" do
    given "the seller is logged in" do
      system_sign_in(@seller)
    end

    when_ "they visit the item and click Edit" do
      visit item_path(@item)
      click_link "Edit"
    end

    then_ "they can update the title and price" do
      fill_in "Title", with: "Updated Textbook"
      fill_in "Price", with: 80
      click_button "Update Item"
    end

    then_ "the item is updated" do
      assert_text "Item updated"
      assert_text "Updated Textbook"
    end
  end

  test "happy path: seller deletes their item" do
    given "the seller is logged in and viewing their item" do
      system_sign_in(@seller)
      visit item_path(@item)
    end

    when_ "they click Delete and confirm" do
      accept_confirm { click_link "Delete" }
    end

    then_ "the item is removed and they're redirected to items" do
      assert_text "Item destroyed"
      assert_current_path items_path, ignore_query: true
      assert_no_text "Old Textbook"
    end
  end

  test "sad path: non-owner cannot see edit/delete buttons" do
    given "another user is logged in" do
      system_sign_in(@other_user)
    end

    when_ "they visit the seller's item" do
      visit item_path(@item)
    end

    then_ "they do not see Edit or Delete buttons" do
      assert_text "Old Textbook"
      assert_no_link "Edit"
      assert_no_link "Delete"
    end
  end
end
