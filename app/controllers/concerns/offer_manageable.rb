module OfferManageable
  extend ActiveSupport::Concern

  included do
    before_action :set_item
    before_action :set_offer
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_offer
    @offer = @item.offers.find(params[:offer_id] || params[:id])
  end

  def authorize_seller!
    unless @item.seller == Current.user
      redirect_back fallback_location: @item, alert: "Not authorized."
    end
  end

  def authorize_buyer!
    unless @offer.buyer == Current.user
      redirect_back fallback_location: @item, alert: "Not authorized."
    end
  end


  def ensure_offer_is_pending!
    unless @offer.pending?
      redirect_back fallback_location: @item, alert: "This offer is no longer pending and cannot be modified."
    end
  end

  def ensure_offer_is_countered!
    unless @offer.countered?
      redirect_back fallback_location: @item, alert: "This offer is not in a countered state."
    end
  end
end
