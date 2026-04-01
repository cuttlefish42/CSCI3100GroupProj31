class Offers::AcceptancesController < ApplicationController
  include OfferManageable
  before_action :authorize_seller!
  before_action :ensure_offer_is_pending!

  def create
    @offer.accept!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "offer_#{@offer.id}",
          partial: "messages/attachments/offer",
          locals: { offer: @offer.reload }
        )
      end
      format.html { redirect_to @item, notice: "Offer accepted. Item is now reserved." }
    end
  end
end
