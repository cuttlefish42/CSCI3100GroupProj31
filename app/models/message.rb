class Message < ApplicationRecord
  # touch: true ensure the timestamp is updated so we know the last conversation's time.
  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: "User"

  belongs_to :item, optional: true
  belongs_to :offer, optional: true

  # update <div id="messages">
  after_create_commit -> { broadcast_append_to conversation, target: "messages" }
end
