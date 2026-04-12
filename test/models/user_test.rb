require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires first_name" do
    user = users(:one)
    user.first_name = nil
    assert_not user.valid?
  end

  test "requires last_name" do
    user = users(:one)
    user.last_name = nil
    assert_not user.valid?
  end

  test "requires email_address" do
    user = users(:one)
    user.email_address = nil
    assert_not user.valid?
  end

  test "enforces unique email_address" do
    duplicate = User.new(
      email_address: users(:one).email_address,
      first_name: "Dup", last_name: "User",
      password: "password123"
    )
    assert_not duplicate.valid?
  end

  test "full_name returns first and last name" do
    user = users(:one)
    assert_equal "#{user.first_name} #{user.last_name}", user.full_name
  end
end
