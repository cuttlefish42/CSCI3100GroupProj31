class Offers::CounterRejectionsController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.rejected!
      redirect_to @item, notice: "Counter-offer rejected. You can make a new offer if you'd like."
    else
      redirect_to @item, alert: "You can only reject a counter-offer."
    end
  end
end
