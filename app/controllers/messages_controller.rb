class MessagesController < ApplicationController
  include ConversationAuthorizable
  before_action :set_conversation
  before_action :authorize_conversation_participation

  def create
    # Build the message associated with this conversation
    @message = @conversation.messages.build(message_params)
    @message.sender = Current.user # Attach the current user as the sender

    # No need redirection since turbo handles the ui update.
    if @message.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  private

  def message_params
    # Notice we permit :item_id and :offer_id here so we can optionally attach them
    params.require(:message).permit(:content, :item_id, :offer_id)
  end
end
