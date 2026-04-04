class Offers::AcceptancesController < ApplicationController
  include OfferManageable
  before_action :authorize_seller!
  before_action :ensure_offer_is_pending!

  def create
    @offer.accept!
    redirect_back fallback_location: @item, notice: "Offer accepted. Item is now reserved."
  end
end
