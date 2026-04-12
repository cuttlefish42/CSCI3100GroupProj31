require "test_helper"

class RemoveStaleItemsJobTest < ActiveJob::TestCase
  test "removes items older than 90 days" do
    stale = Item.create!(
      title: "Old Item", description: "Old stuff", price: 5, condition: :good, status: :available,
      category: categories(:one), seller: users(:one),
      created_at: 91.days.ago
    )

    assert_difference "Item.count", -1 do
      RemoveStaleItemsJob.perform_now
    end

    assert_nil Item.find_by(id: stale.id)
  end

  test "keeps items newer than 90 days" do
    assert_no_difference "Item.count" do
      RemoveStaleItemsJob.perform_now
    end
  end
end
