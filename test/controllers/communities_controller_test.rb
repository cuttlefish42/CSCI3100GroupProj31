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
end
