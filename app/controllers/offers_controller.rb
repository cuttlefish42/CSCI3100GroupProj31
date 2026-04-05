class OffersController < ApplicationController
  include OfferManageable

  skip_before_action :set_offer, only: [ :create ]
  before_action :authorize_buyer!, only: [ :update, :destroy ]

  def create
    unless @item.available?
      redirect_to @item, alert: "This item is no longer available for offers."
      return
    end

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
        content: @offer.message,
        offer: @offer
      )

      UserMailer.new_offer_notify(@item.seller, @item, @offer).deliver_later

      redirect_to @item, notice: "Offer submitted."
    else
      redirect_to @item, alert: @offer.errors.full_messages.to_sentence
    end
  end

  def update
    unless @offer.pending? || @offer.countered?
      redirect_back fallback_location: @item, alert: "You can only edit pending or countered offers."
      return
    end

    permitted = params.require(:offer).permit(:price_offered, :message)
    permitted[:status] = :pending if @offer.countered?

    if @offer.update(permitted)
      redirect_back fallback_location: @item, notice: "Offer updated."
    else
      redirect_back fallback_location: @item, alert: @offer.errors.full_messages.to_sentence
    end
  end

  def destroy
    @offer.destroy
    redirect_back fallback_location: @item, notice: "Offer withdrawn."
  end

  private

  def offer_params
    params.require(:offer).permit(:price_offered, :message)
  end
end
