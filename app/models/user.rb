class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  # Allow default to no community
  belongs_to :default_community, class_name: "Community", optional: true
  has_many :community_memberships, dependent: :destroy
  has_many :communities, through: :community_memberships

  has_many :likes, dependent: :destroy
  has_many :liked_items, through: :likes, source: :item
  has_many :items, foreign_key: :seller_id, dependent: :destroy
  has_many :offers, foreign_key: :buyer_id, dependent: :destroy

  has_many :reviews_given,    class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }
  def full_name
    "#{first_name} #{last_name}"
  end
end
