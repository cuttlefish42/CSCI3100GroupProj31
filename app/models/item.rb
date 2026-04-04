class Item < ApplicationRecord
  belongs_to :category
  # Item is listed on "Global" community unless specified.
  belongs_to :community, optional: true
  belongs_to :seller, class_name: "User"

  has_many :offers, dependent: :destroy
  has_many :messages, dependent: :nullify
  has_one_attached :photo

  enum :condition, { poor: 0, fair: 1, good: 2, like_new: 3, brand_new: 4 }
  enum :status, { available: 0, reserved: 1, sold: 2 }

  geocoded_by :meetup_note
  after_validation :geocode, if: ->(obj) { obj.meetup_note.present? && obj.meetup_note.changed? }

  validate :validate_meetup_note
  def validate_meetup_note
    if latitude.blank? || longitude.blank? # check gps coordinate
      if meetup_note.blank? # check pickup address
        errors.add(:meetup_note, "pick up location cannot be empty!")
      end
    end
  end

  def location_coordinate?
    latitude.present? and longitude.present?
  end

end

