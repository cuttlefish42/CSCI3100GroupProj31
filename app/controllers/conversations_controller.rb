class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.involves(Current.user).recent
  end

  def show
    @conversation = Conversation.find(params[:id])

    unless @conversation.participates?(Current.user)
      redirect_to conversations_path, alert: "You do not have permission to view this conversation."
      return
    end

    # it's already in asc order
    @messages = @conversation.messages
  end

  def create
    receiver = User.find(params[:receiver_id])

    @conversation = Conversation.find_or_create_between(Current.user, receiver)

    redirect_to conversation_path(@conversation)
  end
end
