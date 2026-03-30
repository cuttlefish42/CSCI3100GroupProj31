class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  scope :involves, ->(user) { where(sender: user).or(where(receiver: user)) }

  scope :recent, -> { order(updated_at: desc) }

  # instance methods
  def participates?(user)
    sender_id == user.id || receiver_id == user.id
  end

  # class methods
  def self.between(user1, user2)
    where(sender: user1, receiver: user2).or(where(sender: user2, receiver: user1)).first
  end

  def self.find_or_create_between(user1, user2)
    between(user1, user2) || create!(sender: user1, receiver: user2)
  end
end
