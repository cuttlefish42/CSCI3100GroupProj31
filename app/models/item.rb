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

  private

  def enqueue_thumbnail_job
    ResizeImagesJob.perform_later(id)
  end
end
