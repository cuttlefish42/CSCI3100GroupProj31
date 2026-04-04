class Offers::CounterAcceptancesController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!
  before_action :ensure_offer_is_countered!

  def create
    @offer.accept_counter!
    redirect_back fallback_location: @item, notice: "You accepted the counter-offer of #{helpers.number_to_currency(@offer.counter_price)}. Item is now reserved."
  end
end
