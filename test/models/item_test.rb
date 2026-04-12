require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "valid item from fixtures" do
    assert items(:one).valid?
  end

  test "requires category" do
    item = items(:one)
    item.category = nil
    assert_not item.valid?
  end

  test "requires seller" do
    item = items(:one)
    item.seller = nil
    assert_not item.valid?
  end

  test "condition enum values" do
    assert_equal %w[poor fair good like_new brand_new], Item.conditions.keys
  end

  test "status enum values" do
    assert_equal %w[available reserved sold], Item.statuses.keys
  end

  test "destroying item destroys associated likes" do
    item = items(:one)
    Like.create!(user: users(:one), item: item)
    assert_difference "Like.count", -1 do
      item.destroy
    end
  end

  test "destroying item destroys associated snapshots" do
    item = items(:one)
    assert item.item_snapshots.count > 0
    assert_difference "ItemSnapshot.count", -item.item_snapshots.count do
      item.destroy
    end
  end
end
