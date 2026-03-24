class Offers::AcceptancesController < ApplicationController
  include OfferManageable

  def create
    @offer.accept!
    redirect_to @item, notice: "Offer accepted. Item is now reserved."
  end
end
