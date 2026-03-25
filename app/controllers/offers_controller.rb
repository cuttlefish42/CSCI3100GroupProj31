class OffersController < ApplicationController
  before_action :set_item, except: [ :dashboard ]
  before_action :set_offer, only: [ :update, :destroy ]
  def dashboard
  @sent_sort = params[:sent_sort] || "date"
  @sent_dir = params[:sent_dir] || "desc"
  @recv_sort = params[:recv_sort] || "date"
  @recv_dir = params[:recv_dir] || "desc"

  @sent_offers = Current.user.offers.includes(item: :seller)
  @sent_offers = apply_offer_sort(@sent_offers, @sent_sort, @sent_dir, scope: :sent)

  @received_offers = Offer.received_by(Current.user).includes(:buyer, :item)
  @received_offers = apply_offer_sort(@received_offers, @recv_sort, @recv_dir, scope: :received)
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
    # Buyer editing their own offer (price/message) or responding to counter
    if @offer.buyer == Current.user
      # Buyer accepts the seller's counter-offer
      if params[:offer][:status] == "accept_counter" && @offer.countered?
        @offer.accept_counter!
        redirect_to @item, notice: "You accepted the counter-offer of #{ActionController::Base.helpers.number_to_currency(@offer.counter_price)}. Item is now reserved."
        return
      end

      # Buyer rejects the seller's counter-offer
      if params[:offer][:status] == "reject_counter" && @offer.countered?
        @offer.rejected!
        redirect_to @item, notice: "Counter-offer rejected. You can make a new offer if you'd like."
        return
      end

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

  def apply_offer_sort(offers, sort_by, direction, scope: nil)
    dir = direction == "asc" ? :asc : :desc
    case sort_by
    when "price"
      offers.order(price_offered: dir)
    when "item"
      offers.joins(:item).order("items.title #{dir == :asc ? 'ASC' : 'DESC'}")
    when "buyer"
      if scope == :received
        offers.joins(:buyer).order("users.email_address #{dir == :asc ? 'ASC' : 'DESC'}")
      else
        offers.order(created_at: :desc)
      end
    when "seller"
      if scope == :sent
        offers.joins(item: :seller).order("users.email_address #{dir == :asc ? 'ASC' : 'DESC'}")
      else
        offers.order(created_at: :desc)
      end
    when "status"
      offers.order(status: dir)
    else
      offers.order(created_at: dir)
    end
  end

  def offer_params
    params.require(:offer).permit(:price_offered, :message, :status, :counter_price)
  end
end
