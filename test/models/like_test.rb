require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "valid like" do
    like = Like.new(user: users(:two), item: items(:one))
    assert like.valid?
  end

  test "enforces uniqueness of user and item" do
    # fixture :one already has user(:one) + item(:two)
    duplicate = Like.new(user: users(:one), item: items(:two))
    assert_not duplicate.valid?
  end

  test "requires user" do
    like = Like.new(item: items(:one))
    assert_not like.valid?
  end

  test "requires item" do
    like = Like.new(user: users(:one))
    assert_not like.valid?
  end
end
