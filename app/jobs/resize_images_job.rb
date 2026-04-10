class ResizeImagesJob < ApplicationJob
  queue_as :default

  def perform(listing_id)
    listing = Listing.find_by(id: listing_id)
    return unless listing

    listing.photos.each do |photo|
      next unless photo.content_type&.start_with?("image/")

      begin
        photo.variant(resize_to_limit: [ 300, 300 ]).processed
        photo.variant(resize_to_limit: [ 800, 600 ]).processed
        puts "✅ Resized photo #{photo.id} for listing #{listing_id}"
      rescue => e
        puts "❌ Error resizing photo #{photo.id}: #{e.message}"
      end
    end
  end
end
