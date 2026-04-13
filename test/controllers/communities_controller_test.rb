require "test_helper"

class CommunitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @community = communities(:one)
    @admin = users(:one)
    @non_admin = users(:three)
  end

  test "index loads for unauthenticated users" do
    get communities_path
    assert_response :success
  end

  test "show loads with community items" do
    get community_path(@community)
    assert_response :success
  end

  test "admin can update listing rules" do
    sign_in_as @admin
    patch community_path(@community), params: {
      community: { listing_rules: "New rules here" }
    }
    assert_redirected_to community_path(@community)
  end

  test "non-admin cannot update listing rules" do
    sign_in_as @non_admin
    patch community_path(@community), params: {
      community: { listing_rules: "Hacked rules" }
    }
    assert_redirected_to community_path(@community)
    assert_equal "Not authorized.", flash[:alert]
  end

  test "unauthenticated user cannot update listing rules" do
    patch community_path(@community), params: {
      community: { listing_rules: "Anon rules" }
    }
    assert_redirected_to new_session_path
  end

  test "user can join a community" do
    sign_in_as @non_admin
    assert_difference "CommunityMembership.count", 1 do
      post join_community_path(@community)
    end
    assert_redirected_to community_path(@community)
  end

  test "user can leave a community" do
    sign_in_as users(:two)
    assert_difference "CommunityMembership.count", -1 do
      delete leave_community_path(@community)
    end
    assert_redirected_to community_path(@community)
  end

  test "admin cannot leave community" do
    sign_in_as @admin
    assert_no_difference "CommunityMembership.count" do
      delete leave_community_path(@community)
    end
    assert_equal "Admins cannot leave their community.", flash[:alert]
  end

  test "my feed filters items to joined communities" do
    sign_in_as users(:two)
    get items_path(feed: "my")
    assert_response :success
  end
end
