module ConversationAuthorizable
  extend ActiveSupport::Concern

  private

  # Finds the conversation whether we are in ConversationsController (uses params[:id])
  # or MessagesController (uses params[:conversation_id])
  def set_conversation
    conversation_id = params[:conversation_id] || params[:id]
    @conversation = Conversation.find(conversation_id)
  end

  # Reusable authorization check
  def authorize_conversation_participation
    unless @conversation.participates?(Current.user)
      redirect_to conversations_path, alert: "You do not have permission to access this conversation."
    end
  end
end
