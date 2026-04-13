class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_items = @user.items.order(created_at: :desc).limit(10)
    @completed_trades = @user.offers.where(status: :completed).includes(:item).order(updated_at: :desc).limit(10)
    @reviews_received = @user.reviews_received.includes(:reviewer, offer: :item).order(created_at: :desc)
  end
end
