class ConversationsController < ApplicationController
  include ConversationAuthorizable
  before_action :set_conversation, only: [ :show ]
  before_action :authorize_conversation_participation, only: [ :show ]

  def index
    @conversations = Conversation.involves(Current.user).recent
  end

  def show
    @messages = @conversation.messages
    @message = Message.new
    @item = Item.find_by(id: params[:item_id])
  end

  def create
    receiver = User.find(params[:receiver_id])

    @conversation = Conversation.find_or_create_between(Current.user, receiver)

    redirect_to conversation_path(@conversation, item_id: params[:item_id])
  end
end
