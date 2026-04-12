class Item < ApplicationRecord
  belongs_to :category
  # Item is listed on "Global" community unless specified.
  belongs_to :community, optional: true
  belongs_to :seller, class_name: "User"

  has_many :likes, dependent: :destroy
  has_many :item_snapshots, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :messages, dependent: :nullify
  has_one_attached :photo

  enum :condition, { poor: 0, fair: 1, good: 2, like_new: 3, brand_new: 4 }
  enum :status, { available: 0, reserved: 1, sold: 2 }

  after_commit :enqueue_thumbnail_job, on: [ :create, :update ], if: -> { photo.attached? }

  # Scopes for filtering and searching
  scope :search_by_keyword, ->(keyword) {
    where("title ILIKE ?", "%#{keyword}%") if keyword.present?
  }

  scope :by_community, ->(community_id) {
    where(community_id: community_id) if community_id.present?
  }

  scope :by_price_range, ->(min_price, max_price) {
    query = all
    query = query.where("price >= ?", min_price.to_f) if min_price.present?
    query = query.where("price <= ?", max_price.to_f) if max_price.present?
    query
  }

  scope :by_date_range, ->(start_date, end_date) {
    query = all
    if start_date.present?
      query = query.where("created_at >= ?", Time.zone.parse(start_date).beginning_of_day)
    end
    if end_date.present?
      query = query.where("created_at <= ?", Time.zone.parse(end_date).end_of_day)
    end
    query
  }

  scope :sorted, ->(sort_by = "date", sort_direction = "desc") {
    direction = sort_direction.to_sym
    case sort_by
    when "price"
      order(price: direction)
    when "date"
      order(created_at: direction)
    else
      order(created_at: direction)
    end
  }

  private

  def enqueue_thumbnail_job
    ResizeImagesJob.perform_later(id)
  end
end
