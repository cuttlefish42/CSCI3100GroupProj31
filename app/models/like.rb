class Like < ApplicationRecord
  belongs_to :user
  belongs_to :item, counter_cache: true

  validates :user_id, uniqueness: { scope: :item_id }
end
