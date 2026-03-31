class ConversationsController < ApplicationController
  include ConversationAuthorizable
  before_action :set_conversation, only: [ :show ]
  before_action :authorize_conversation_participation, only: [ :show ]

  def index
    @conversations = Conversation.involves(Current.user).recent
  end

  def show
    # it's already in asc order
    @messages = @conversation.messages
    @message = Message.new
  end

  def create
    receiver = User.find(params[:receiver_id])

    @conversation = Conversation.find_or_create_between(Current.user, receiver)

    redirect_to conversation_path(@conversation)
  end
end
