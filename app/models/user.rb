class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  belongs_to :default_community, class_name: "Community", dependent: :destroy
  has_many :items, foreign_key: :seller_id, dependent: :destroy
end
