class Item < ApplicationRecord
  belongs_to :category
  belongs_to :community
  belongs_to :seller
end
