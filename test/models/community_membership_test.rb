require "test_helper"

class CommunityMembershipTest < ActiveSupport::TestCase
  test "valid membership from fixtures" do
    assert community_memberships(:admin_one).valid?
  end

  test "enforces uniqueness of user per community" do
    duplicate = CommunityMembership.new(
      community: communities(:one),
      user: users(:one),
      role: :member
    )
    assert_not duplicate.valid?
  end

  test "role enum values" do
    assert_equal %w[member admin], CommunityMembership.roles.keys
  end
end
