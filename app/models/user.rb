class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  # Allow default to no community
  belongs_to :default_community, class_name: "Community", optional: true, dependent: :destroy

  has_many :items, foreign_key: :seller_id, dependent: :destroy
  has_many :offers, foreign_key: :buyer_id, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end

