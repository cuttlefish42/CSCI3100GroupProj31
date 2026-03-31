class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  belongs_to :item, optional: true
  belongs_to :offer, optional: true
end
