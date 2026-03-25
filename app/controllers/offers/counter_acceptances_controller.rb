class Offers::CounterAcceptancesController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.accept_counter!
      redirect_to @item, notice: "You accepted the counter-offer of #{helpers.number_to_currency(@offer.counter_price)}. Item is now reserved."
    else
      redirect_to @item, alert: "You can only accept a counter-offer."
    end
  end
end
