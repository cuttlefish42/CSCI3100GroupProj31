class Offers::CounterAcceptancesController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.accept_counter!

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "offer_#{@offer.id}",
            partial: "messages/attachments/offer",
            locals: { offer: @offer.reload }
          )
        end
        format.html { redirect_to @item, notice: "You accepted the counter-offer of #{helpers.number_to_currency(@offer.counter_price)}. Item is now reserved." }
      end
    else
      redirect_to @item, alert: "You can only accept a counter-offer."
    end
  end
end
