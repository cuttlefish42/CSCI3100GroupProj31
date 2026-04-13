class Community < ApplicationRecord
  has_many :items
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :admins, -> { where(community_memberships: { role: :admin }) }, through: :community_memberships, source: :user

  has_rich_text :listing_rules

  validates :name, presence: true, uniqueness: true

  scope :grouped_by_type, -> { order(:community_type, :name).group_by(&:community_type) }

  scope :with_counts, -> {
    select("communities.*,
      (SELECT COUNT(*) FROM items WHERE items.community_id = communities.id AND items.status = 0) AS items_count,
      (SELECT COUNT(*) FROM community_memberships WHERE community_memberships.community_id = communities.id) AS members_count")
  }

  scope :grouped_by_type_with_counts, -> { with_counts.order(:community_type, :name).group_by(&:community_type) }

  def admin?(user)
    community_memberships.exists?(user: user, role: :admin)
  end

  def member?(user)
    community_memberships.exists?(user: user)
  end
end
