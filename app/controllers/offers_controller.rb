class OffersController < ApplicationController
  before_action :set_item, except: [ :dashboard ]
  before_action :set_offer, only: [ :update, :destroy ]
  def dashboard
    @sent_offers = Current.user.offers.includes(item: :seller).order(created_at: :desc)
    @received_offers = Offer.received_by(Current.user)
                            .includes(:buyer, :item)
                            .recent
  end

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
    # Buyer editing their own offer (price/message)
    if @offer.buyer == Current.user
      if @offer.pending? || @offer.countered?
        new_price = params[:offer][:price_offered]
        new_message = params[:offer][:message]
        updates = {}
        updates[:price_offered] = new_price.to_f if new_price.present? && new_price.to_f > 0
        updates[:message] = new_message if params[:offer].key?(:message)
        updates[:status] = :pending if @offer.countered?

        if updates.any? && @offer.update(updates)
          redirect_to @item, notice: "Offer updated."
        else
          redirect_to @item, alert: "Could not update offer. Make sure the price is greater than zero."
        end
      else
        redirect_to @item, alert: "You can only edit pending or countered offers."
      end
      return
    end

    # Seller actions (accept/reject/counter)
    unless @item.seller == Current.user
      redirect_to @item, alert: "Not authorized."
      return
    end

    case params[:offer][:status]
    when "accepted"
      @offer.accept!
      redirect_to @item, notice: "Offer accepted. Item is now reserved."
    when "rejected"
      @offer.rejected!
      redirect_to @item, notice: "Offer rejected."
    when "countered"
      counter_price = params[:offer][:counter_price]
      if counter_price.present? && counter_price.to_f > 0
        @offer.counter!(counter_price.to_f)
        redirect_to @item, notice: "Counter-offer sent."
      else
        redirect_to @item, alert: "Counter price must be greater than zero."
      end
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
end
