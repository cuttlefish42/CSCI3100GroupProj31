class OffersController < ApplicationController
  before_action :set_item, except: [ :dashboard ]
  before_action :set_offer, only: [ :update, :destroy ]
  before_action :authorize_seller!, only: [ :update ]

  def dashboard
    @sent_offers = Current.user.offers.includes(item: :seller).order(created_at: :desc)
    @received_offers = Offer.joins(:item)
                            .where(items: { seller_id: Current.user.id })
                            .includes(:buyer, :item)
                            .order(created_at: :desc)
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

  def offer_params
    params.require(:offer).permit(:price_offered, :message)
  end

  def authorize_seller!
    unless @item.seller == Current.user
      redirect_to @item, alert: "Not authorized."
      return
    end
  end
end
