class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_items = @user.items.order(created_at: :desc).limit(10)
    @completed_trades = Offer.where(status: :completed)
      .where(buyer_id: @user.id).or(Offer.where(status: :completed).joins(:item).where(items: { seller_id: @user.id }))
      .includes(item: :seller, buyer: [])
      .order(updated_at: :desc).limit(10)
    @reviews_received = @user.reviews_received.includes(:reviewer, offer: :item).order(created_at: :desc)
  end
end
