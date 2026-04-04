class Offer < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :item

  has_many :messages, dependent: :nullify

  enum :status, { pending: 0, accepted: 1, rejected: 2, countered: 3 }

  validate :buyer_is_not_seller
  validates :price_offered, numericality: { greater_than: 0 }
  validates :counter_price, numericality: { greater_than: 0 }, allow_nil: true
  validate :no_duplicate_pending_offer, on: :create
  validate :item_must_be_available, on: :create

  scope :received_by, ->(user) { joins(:item).where(items: { seller_id: user.id }) }
  scope :recent, -> { order(created_at: :desc) }

  after_update_commit :broadcast_offer_updates

  # ---------- Ordering ----------
  scope :order_by_price, ->(dir) { order(price_offered: dir) }
  scope :order_by_status, ->(dir) { order(status: dir) }
  scope :order_by_date, ->(dir) { order(created_at: dir) }
  scope :order_by_item_title, ->(dir) {
    joins(:item).order("items.title #{dir == :asc ? 'ASC' : 'DESC'}")
  }
  scope :order_by_buyer_email, ->(dir) {
    joins(:buyer).order("users.email_address #{dir == :asc ? 'ASC' : 'DESC'}")
  }
  scope :order_by_seller_email, ->(dir) {
    joins(item: :seller).order("users.email_address #{dir == :asc ? 'ASC' : 'DESC'}")
  }
  # --------------------

  def self.sorted_by(sort_by, dir, scope: nil)
    case sort_by
    when "price"  then order_by_price(dir)
    when "item"   then order_by_item_title(dir)
    when "status" then order_by_status(dir)
    when "buyer"
      scope == :received ? order_by_buyer_email(dir) : order_by_date(:desc)
    when "seller"
      scope == :sent ? order_by_seller_email(dir) : order_by_date(:desc)
    else
      order_by_date(dir)
    end
  end

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

  def accept_counter!
    transaction do
      update!(price_offered: counter_price, status: :accepted)
      item.reserved!
      item.offers.pending.where.not(id: id).find_each(&:rejected!)
    end
  end

  private

  def broadcast_offer_updates
    # Update chat offer card for buyer
    broadcast_replace_to("user_#{buyer_id}_offer_updates",
      target: "offer_#{id}",
      partial: "messages/attachments/offer",
      locals: { offer: self, viewer: buyer })

    # Update dashboard "sent" row for buyer
    broadcast_replace_to("user_#{buyer_id}_offer_updates",
      target: "sent_offer_#{id}",
      partial: "dashboards/sent_offer_row",
      locals: { offer: self })

    # Update chat offer card for seller
    broadcast_replace_to("user_#{item.seller_id}_offer_updates",
      target: "offer_#{id}",
      partial: "messages/attachments/offer",
      locals: { offer: self, viewer: item.seller })

    # Update dashboard "received" row for seller
    broadcast_replace_to("user_#{item.seller_id}_offer_updates",
      target: "received_offer_#{id}",
      partial: "dashboards/received_offer_row",
      locals: { offer: self })
  end

  def buyer_is_not_seller
    errors.add(:buyer, "cannot be the seller") if buyer_id == item&.seller_id
  end

  def item_must_be_available
    if item && !item.available?
      errors.add(:base, "This item is no longer available for offers.")
    end
  end

  def no_duplicate_pending_offer
    scope = item.offers.where(buyer_id: buyer_id).where(status: [ :pending, :countered ])
    scope = scope.where.not(id: id) if persisted?
    if item && buyer_id && scope.exists?
      errors.add(:base, "You already have an active offer on this item. Please edit your existing offer instead.")
    end
  end
end
