class Offers::CounterRejectionsController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!
  before_action :ensure_offer_is_countered!

  def create
    @offer.rejected!
    redirect_to @item, notice: "Counter-offer rejected. You can make a new offer if you'd like."
  end
end
