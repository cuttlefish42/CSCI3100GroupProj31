class Offers::CounterAcceptancesController < ApplicationController
  before_action :set_item_and_offer
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.accept_counter!
      redirect_to @item, notice: "You accepted the counter-offer of #{helpers.number_to_currency(@offer.counter_price)}. Item is now reserved."
    else
      redirect_to @item, alert: "You can only accept a counter-offer."
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
