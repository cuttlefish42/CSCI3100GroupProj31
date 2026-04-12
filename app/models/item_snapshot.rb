class ItemSnapshot < ApplicationRecord
  belongs_to :item

  scope :between, ->(from, to) { where(recorded_at: from..to) }
end
