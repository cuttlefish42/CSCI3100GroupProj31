require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "valid category from fixtures" do
    assert categories(:one).valid?
  end
end
