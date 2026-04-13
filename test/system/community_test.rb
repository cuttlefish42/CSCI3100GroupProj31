require "application_system_test_case"

class CommunityTest < ApplicationSystemTestCase
  test "user can browse communities index" do
    given "communities exist" do
      create_sample_communities
    end

    when_ "the user visits the communities page" do
      visit communities_path
    end

    then_ "the user can see communities listed" do
      assert_text "Chung Chi College"
    end
  end

  test "user can view community hub page with listing rules" do
    given "a community with listing rules exists" do
      create_sample_communities
      community = Community.find_by!(name: "Chung Chi College")
      community.update!(listing_rules: "No electronics allowed in this community.")
    end

    when_ "the user visits the community page" do
      visit community_path(Community.find_by!(name: "Chung Chi College"))
    end

    then_ "the user can see the listing rules" do
      assert_text "No electronics allowed in this community."
    end
  end

  test "user can join and leave a community" do
    given "a community exists and user is logged in" do
      create_sample_communities
      @user = create_sample_user
      system_sign_in(@user)
    end

    when_ "the user visits the community and clicks Join" do
      visit community_path(Community.find_by!(name: "Chung Chi College"))
      click_button "Join"
    end

    then_ "the user has joined the community" do
      assert_text "Joined Chung Chi College"
      assert_button "Leave"
    end

    when_ "the user clicks Leave" do
      click_button "Leave"
    end

    then_ "the user has left the community" do
      assert_text "Left Chung Chi College"
      assert_button "Join"
    end
  end

  test "my feed shows items from joined communities only" do
    given "a user has joined a community with items" do
      create_sample_communities
      create_sample_items(count: 1)
      @user = create_sample_user(email_address: "feeder@link.cuhk.edu.hk", first_name: "Feed", last_name: "User")
      community = Community.find_by!(name: "Chung Chi College")
      CommunityMembership.create!(user: @user, community: community, role: :member)
      system_sign_in(@user)
    end

    when_ "the user clicks My Feed in the sidebar" do
      visit items_path(feed: "my")
    end

    then_ "the user sees items from their joined community" do
      assert_text "Sample Item 1"
    end
  end

  test "admin can edit listing rules" do
    given "an admin user and community exist" do
      create_sample_communities
      @admin = create_sample_user(email_address: "admin@link.cuhk.edu.hk", first_name: "Admin", last_name: "User")
      community = Community.find_by!(name: "Chung Chi College")
      CommunityMembership.create!(user: @admin, community: community, role: :admin)
      system_sign_in(@admin)
    end

    when_ "the admin visits the community and edits rules" do
      visit community_path(Community.find_by!(name: "Chung Chi College"))
      click_button "Edit Rules"
      within("#rules-form") do
        find("trix-editor").click.set("Only textbooks allowed here.")
        click_button "Save Rules"
      end
    end

    then_ "the listing rules are updated" do
      assert_text "Listing rules updated"
      assert_text "Only textbooks allowed here."
    end
  end
end
