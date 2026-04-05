class Offers::CountersController < ApplicationController
  include OfferManageable
  before_action :authorize_seller!
  before_action :ensure_offer_is_pending!

  def create
    if params[:counter_price].to_f > 0
      @offer.counter!(params[:counter_price].to_f)
      redirect_back fallback_location: @item, notice: "Counter-offer sent."
    else
      redirect_back fallback_location: @item, alert: "Counter price must be greater than zero."
    end
  end
end
