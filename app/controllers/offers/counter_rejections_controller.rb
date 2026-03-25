class Offers::CounterRejectionsController < ApplicationController
  before_action :set_item_and_offer
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.rejected!
      redirect_to @item, notice: "Counter-offer rejected. You can make a new offer if you'd like."
    else
      redirect_to @item, alert: "You can only reject a counter-offer."
    end
  end

  private

  def set_item_and_offer
    @item = Item.find(params[:item_id])
    @offer = @item.offers.find(params[:offer_id])
  end

  def authorize_buyer!
    unless @offer.buyer == Current.user
      redirect_to @item, alert: "Not authorized."
    end
  end
end
