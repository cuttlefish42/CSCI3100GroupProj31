class Offers::RejectionsController < ApplicationController
  include OfferManageable

  def create
    @offer.rejected!
    redirect_to @item, notice: "Offer rejected."
  end
end
