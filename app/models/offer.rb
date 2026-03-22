class Offer < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :item

  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  validate :buyer_is_not_seller

  def accept!
    transaction do
      accepted!
      item.reserved!
      item.offers.pending.where.not(id: id).find_each(&:rejected!)
    end
  end

  private

  def buyer_is_not_seller
    errors.add(:buyer, "cannot be the seller") if buyer_id == item&.seller_id
  end
end
