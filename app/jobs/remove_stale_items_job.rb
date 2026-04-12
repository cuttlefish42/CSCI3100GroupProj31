class RemoveStaleItemsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    stale_items = Item.where('created_at < ?', 90.days.ago)
    
    count = stale_items.count
    
    if count > 0
      Rails.logger.info "Removing #{count} stale items:"
      stale_items.find_each do |item|
        # Use id since there's no title column
        Rails.logger.info "  - Deleting Item ##{item.id} (created #{item.created_at.to_date})"
      end
      stale_items.destroy_all
    else
      Rails.logger.info "No stale items found"
    end
    
    count
  end
end
