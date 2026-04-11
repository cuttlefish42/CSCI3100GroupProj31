class ResizeImagesJob < ApplicationJob
  queue_as :default

  THUMBNAIL_VARIANT = { resize_to_limit: [ 300, 300 ] }.freeze
  PREVIEW_VARIANT   = { resize_to_limit: [ 800, 600 ] }.freeze

  def perform(item_id)
    item = Item.find_by(id: item_id)
    return unless item&.photo&.attached?
    return unless item.photo.content_type&.start_with?("image/")

    item.photo.variant(THUMBNAIL_VARIANT).processed
    item.photo.variant(PREVIEW_VARIANT).processed
    Rails.logger.info "Resized photo for item #{item_id}"
  end
end
