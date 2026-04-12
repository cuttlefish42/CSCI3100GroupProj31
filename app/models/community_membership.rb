class CommunityMembership < ApplicationRecord
  belongs_to :community
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :community_id }
end
