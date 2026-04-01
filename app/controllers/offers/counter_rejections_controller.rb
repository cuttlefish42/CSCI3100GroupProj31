class Offers::CounterRejectionsController < ApplicationController
  include OfferManageable
  before_action :authorize_buyer!

  def create
    if @offer.countered?
      @offer.rejected!

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "offer_#{@offer.id}",
            partial: "messages/attachments/offer",
            locals: { offer: @offer.reload }
          )
        end
        format.html { redirect_to @item, notice: "Counter-offer rejected. You can make a new offer if you'd like." }
      end
    else
      redirect_to @item, alert: "You can only reject a counter-offer."
    end
  end
end
