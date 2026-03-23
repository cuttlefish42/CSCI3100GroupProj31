class Offers::BaseController < ApplicationController
  before_action :set_item
  before_action :set_offer
  before_action :authorize_seller!
  before_action :ensure_offer_is_pending!

  private

  def authorize_seller!
    unless @item.seller == Current.user
      redirect_to @item, alert: "Not authorized."
    end
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_offer
    @offer = @item.offers.find(params[:offer_id])
  end

  def ensure_offer_is_pending!
    unless @offer.pending?
      redirect_to @item, alert: "This offer is no longer pending and cannot be modified."
    end
  end
end
