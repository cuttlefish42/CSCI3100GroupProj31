class Item < ApplicationRecord
  belongs_to :category
  # Item is listed on "Global" community unless specified.
  belongs_to :community, optional: true
  belongs_to :seller, class_name: "User"

  enum :condition, { poor: 0, fair: 1, good: 2, like_new: 3, brand_new: 4 }
  enum :status, { available: 0, reserved: 1, sold: 2 }
end
