class RecordItemSnapshotsJob < ApplicationJob
  queue_as :default

  def perform
    recorded_at = Time.current.beginning_of_hour
    now = Time.current

    snapshots = Item.where(status: [ :available, :reserved ])
      .pluck(:id, :views_count, :likes_count)
      .map do |id, views, likes|
        {
          item_id: id,
          views_count: views,
          likes_count: likes,
          recorded_at: recorded_at,
          created_at: now,
          updated_at: now
        }
      end

    ItemSnapshot.insert_all(snapshots) if snapshots.any?

    Rails.logger.info "Recorded #{snapshots.size} item snapshots at #{recorded_at}"
  end
end
