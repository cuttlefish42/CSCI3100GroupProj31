class Review < ApplicationRecord
  belongs_to :offer
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"

  enum :role, { seller_review: 0, buyer_review: 1 }

  validates :rating, inclusion: { in: [ -1, 1 ] }
  validates :offer_id, uniqueness: { scope: :role, message: "has already been reviewed" }
  validate  :offer_must_be_accepted
  validate  :reviewer_must_be_party_to_offer

  after_create :apply_karma_change
  after_create :complete_transaction

  private

  def offer_must_be_accepted
    errors.add(:offer, "must be an accepted transaction") unless offer&.accepted? || offer&.completed?
  end

  def reviewer_must_be_party_to_offer
    return unless offer && offer.item

    if seller_review?
      unless reviewer_id == offer.buyer_id && reviewee_id == offer.item.seller_id
        errors.add(:base, "Only the buyer can review the seller")
      end
    elsif buyer_review?
      unless reviewer_id == offer.item.seller_id && reviewee_id == offer.buyer_id
        errors.add(:base, "Only the seller can review the buyer")
      end
    end
  end

  def apply_karma_change
    field = seller_review? ? :seller_karma : :buyer_karma
    Review.transaction do
      reviewee.increment!(field, rating)
      reviewee.increment!(:karma, rating)
    end
  end

  def complete_transaction
    return unless offer.accepted?
    return unless offer.reviews.where(role: [ :seller_review, :buyer_review ]).count == 2

    offer.completed!
    offer.item.sold!
  end
end
