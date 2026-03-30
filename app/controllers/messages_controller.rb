class MessagesController < ApplicationController
  include ConversationAuthorizable
  before_action :set_conversation
  before_action :authorize_conversation_participation

  def create
    # Build the message associated with this conversation
    @message = @conversation.messages.build(message_params)
    @message.sender = Current.user # Attach the current user as the sender

    if @message.save
      # Update the conversation's updated_at timestamp so it jumps to the top of the inbox
      @conversation.touch

      # Standard Rails redirect (we will replace this with Hotwire/Turbo later)
      redirect_to conversation_path(@conversation)
    else
      # If the message fails to save (e.g., content is blank)
      redirect_to conversation_path(@conversation), alert: "Message could not be sent."
    end
  end

  private

  def message_params
    # Notice we permit :item_id and :offer_id here so we can optionally attach them
    params.require(:message).permit(:content, :item_id, :offer_id)
  end
end
