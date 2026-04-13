require "test_helper"

class RecordItemSnapshotsJobTest < ActiveJob::TestCase
  test "creates snapshots for available and reserved items" do
    available_count = Item.where(status: [ :available, :reserved ]).count
    assert available_count > 0

    assert_difference "ItemSnapshot.count", available_count do
      RecordItemSnapshotsJob.perform_now
    end

    snapshot = ItemSnapshot.order(:created_at).last
    assert_equal snapshot.recorded_at, Time.current.beginning_of_hour
  end

  test "skips sold items" do
    sold = Item.create!(
      title: "Sold Thing", description: "Gone", price: 5, condition: :good, status: :sold,
      category: categories(:one), seller: users(:one)
    )

    RecordItemSnapshotsJob.perform_now

    assert_nil ItemSnapshot.find_by(item_id: sold.id)
  end

  test "snapshots capture correct counts" do
    item = items(:one)
    item.update_columns(views_count: 42, likes_count: 7)

    RecordItemSnapshotsJob.perform_now

    snapshot = ItemSnapshot.find_by(item_id: item.id, recorded_at: Time.current.beginning_of_hour)
    assert_equal 42, snapshot.views_count
    assert_equal 7, snapshot.likes_count
  end

  test "handles zero eligible items" do
    Item.update_all(status: :sold)

    assert_no_difference "ItemSnapshot.count" do
      RecordItemSnapshotsJob.perform_now
    end
  end
end
