class Offer < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :item

  enum :status, { pending: 0, accepted: 1, rejected: 2, countered: 3 }

  validate :buyer_is_not_seller
  validates :price_offered, numericality: { greater_than: 0 }
  validates :counter_price, numericality: { greater_than: 0 }, allow_nil: true
  validate :no_duplicate_pending_offer, on: :create

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
    if item && buyer_id && item.offers.where(buyer_id: buyer_id).where(status: [ :pending, :countered ]).exists?
      errors.add(:base, "You already have an active offer on this item. Please edit your existing offer instead.")
    end
  end
end
