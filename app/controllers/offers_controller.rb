class OffersController < ApplicationController
  before_action :set_item
  before_action :set_offer, only: [ :update, :destroy ]

  def create
    existing = @item.offers.where(buyer_id: Current.user.id, status: [ :pending, :countered ]).first
    if existing
      # Buyer already has an active offer — update it instead of creating a duplicate
      if existing.update(offer_params.merge(status: :pending))
        redirect_to @item, notice: "Offer updated."
      else
        redirect_to @item, alert: existing.errors.full_messages.to_sentence
      end
      return
    end

    @offer = @item.offers.build(offer_params)
    @offer.buyer = Current.user

    if @offer.save
      # Automatically send a message in the chat
      conversation = Conversation.find_or_create_between(Current.user, @item.seller)
      conversation.messages.create!(
        sender: Current.user,
        content: "I made an offer for $#{@offer.price_offered}",
        offer: @offer
      )

      redirect_to @item, notice: "Offer submitted."
    else
      redirect_to @item, alert: @offer.errors.full_messages.to_sentence
    end
  end

  def update
    unless @offer.buyer == Current.user
      redirect_to @item, alert: "Not authorized."
      return
    end

    unless @offer.pending? || @offer.countered?
      redirect_to @item, alert: "You can only edit pending or countered offers."
      return
    end

    permitted = params.require(:offer).permit(:price_offered, :message)
    permitted[:status] = :pending if @offer.countered?

    if @offer.update(permitted)
      redirect_to @item, notice: "Offer updated."
    else
      redirect_to @item, alert: @offer.errors.full_messages.to_sentence
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
    params.require(:offer).permit(:price_offered, :message, :status, :counter_price)
  end
end
