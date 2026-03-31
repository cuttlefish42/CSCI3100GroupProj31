class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  belongs_to :item, optional: true
  belongs_to :offer, optional: true

  # update <div id="messages">
  after_create_commit -> { broadcast_append_to conversation, target: "messages" }
end
