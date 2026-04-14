class Message < ApplicationRecord
  # touch: true ensure the timestamp is updated so we know the last conversation's time.
  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: "User"

  belongs_to :item, optional: true
  belongs_to :offer, optional: true

  # Broadcast to each participant separately so is_mine renders correctly per user
  after_create_commit :broadcast_to_participants

  private

  def broadcast_to_participants
    conversation.participants.each do |user|
      broadcast_append_to(
        [user, conversation],
        target: "messages",
        locals: { message: self, current_user: user }
      )
    end
  end
end
