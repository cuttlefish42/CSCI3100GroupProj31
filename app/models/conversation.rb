class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  def self.between(user1, user2)
    where(sender: user1, receiver: user2).or(where(sender: user2, receiver: user1)).first
  end
end
