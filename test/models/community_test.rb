require "test_helper"

class CommunityTest < ActiveSupport::TestCase
  test "valid community from fixtures" do
    assert communities(:one).valid?
  end
end
