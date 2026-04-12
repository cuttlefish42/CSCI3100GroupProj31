class Community < ApplicationRecord
  has_many :items
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :admins, -> { where(community_memberships: { role: :admin }) }, through: :community_memberships, source: :user

  has_rich_text :listing_rules

  validates :name, presence: true, uniqueness: true

  scope :grouped_by_type, -> { order(:community_type, :name).group_by(&:community_type) }
end
