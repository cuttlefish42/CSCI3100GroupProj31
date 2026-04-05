class Offers::RejectionsController < ApplicationController
  include OfferManageable
  before_action :authorize_seller!
  before_action :ensure_offer_is_pending!

  def create
    @offer.rejected!
    redirect_back fallback_location: @item, notice: "Offer rejected."
  end
end
