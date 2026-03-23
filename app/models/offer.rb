class Offer < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :item

  enum :status, { pending: 0, accepted: 1, rejected: 2, countered: 3 }

  validate :buyer_is_not_seller
  validates :price_offered, numericality: { greater_than: 0 }
  validates :counter_price, numericality: { greater_than: 0 }, allow_nil: true
  validate :no_duplicate_pending_offer, on: :create

  scope :received_by, ->(user) { joins(:item).where(items: { seller_id: user.id }) }
  scope :recent, -> { order(created_at: :desc) }

  def accept!
    transaction do
      accepted!
      item.reserved!
      item.offers.pending.where.not(id: id).find_each(&:rejected!)
    end
  end

  def counter!(new_price)
    transaction do
      update!(status: :countered, counter_price: new_price)
    end
  end

  private

  def buyer_is_not_seller
    errors.add(:buyer, "cannot be the seller") if buyer_id == item&.seller_id
  end

  def no_duplicate_pending_offer
    if item && buyer_id && item.offers.pending.where(buyer_id: buyer_id).exists?
      errors.add(:base, "You already have a pending offer on this item")
    end
  end
end
