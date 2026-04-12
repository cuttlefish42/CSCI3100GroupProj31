# db/seeds/07_item_snapshots.rb

puts "Seeding item snapshots..."

now = Time.current.beginning_of_hour
hours = 7.days / 1.hour # 168 data points

Item.find_each do |item|
  snapshots = hours.to_i.times.map do |i|
    recorded_at = now - (hours - i).hours
    views = (i * rand(1..3)).clamp(0, item.views_count)
    likes = (i / 10.0 * rand(0.5..1.5)).floor.clamp(0, item.likes_count)

    {
      item_id: item.id,
      views_count: views,
      likes_count: likes,
      recorded_at: recorded_at,
      created_at: recorded_at,
      updated_at: recorded_at
    }
  end

  ItemSnapshot.insert_all(snapshots)
  puts "  Created #{snapshots.size} snapshots for #{item.title}"
end
