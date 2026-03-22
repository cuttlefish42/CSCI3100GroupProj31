class OffersController < ApplicationController
  before_action :set_item
  before_action :set_offer, only: [ :update, :destroy ]

  def create
    @offer = @item.offers.build(offer_params)
    @offer.buyer = Current.user

    if @offer.save
      redirect_to @item, notice: "Offer submitted."
    else
      redirect_to @item, alert: @offer.errors.full_messages.to_sentence
    end
  end

  def update
    authorize_seller!

    if params[:offer][:status] == "accepted"
      @offer.accept!
      redirect_to @item, notice: "Offer accepted. Item is now reserved."
    elsif params[:offer][:status] == "rejected"
      @offer.rejected!
      redirect_to @item, notice: "Offer rejected."
    else
      redirect_to @item, alert: "Invalid status."
    end
  end

  def destroy
    if @offer.buyer == Current.user
      @offer.destroy
      redirect_to @item, notice: "Offer withdrawn."
    else
      redirect_to @item, alert: "Not authorized."
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_offer
    @offer = @item.offers.find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(:price_offered)
  end

  def authorize_seller!
    redirect_to @item, alert: "Not authorized." unless @item.seller == Current.user
  end
end
