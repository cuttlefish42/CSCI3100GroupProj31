module OfferManageable
  extend ActiveSupport::Concern

  included do
    before_action :set_item_and_offer
    before_action :authorize_seller!
    before_action :ensure_offer_is_pending!
  end

  private
  def authorize_seller!
    unless @item.seller == Current.user
      redirect_to @item, alert: "Not authorized."
    end
  end

  def set_item_and_offer
    @item = Item.find(params[:item_id])
    @offer = @item.offers.find(params[:offer_id])
  end


  def ensure_offer_is_pending!
    unless @offer.pending?
      redirect_to @item, alert: "This offer is no longer pending and cannot be modified."
    end
  end
end
