require "application_system_test_case"

class UserProfileTest < ApplicationSystemTestCase
  setup do
    create_sample_communities
    create_sample_categories

    @seller = create_sample_user(
      email_address: "seller@link.cuhk.edu.hk",
      first_name: "Seller", last_name: "Wang"
    )
    @viewer = create_sample_user(
      email_address: "viewer@link.cuhk.edu.hk",
      first_name: "Viewer", last_name: "Chen"
    )
    category = Category.find_by!(name: "Books")
    community = Community.find_by!(name: "Chung Chi College")
    @item = Item.create!(
      title: "Seller's Textbook", description: "A great book", price: 100,
      condition: :good, status: :available,
      category: category, community: community, seller: @seller
    )
  end

  test "happy path: user views another user's profile with items" do
    given "a viewer is logged in" do
      system_sign_in(@viewer)
    end

    when_ "they visit the seller's profile" do
      visit user_path(@seller)
    end

    then_ "they see the seller's name, karma, and items" do
      assert_text "Seller Wang"
      assert_text "Karma"
      assert_text "Seller's Textbook"
    end
  end

  test "happy path: profile shows tabs for items, trades, reviews" do
    given "a viewer is logged in" do
      system_sign_in(@viewer)
    end

    when_ "they visit the seller's profile" do
      visit user_path(@seller)
    end

    then_ "they see all three tabs" do
      assert_selector "input[aria-label='Items for Sale']"
      assert_selector "input[aria-label='Completed Trades']"
      assert_selector "input[aria-label='Reviews']"
    end
  end

  test "sad path: unauthenticated user is redirected to login" do
    when_ "a guest visits a profile" do
      visit user_path(@seller)
    end

    then_ "they are redirected to sign in" do
      assert_current_path new_session_path, ignore_query: true
    end
  end
end
