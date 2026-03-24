class DashboardsController < ApplicationController
  def show
    @sent_offers = Current.user.offers.includes(item: :seller).recent
    @received_offers = Offer.received_by(Current.user)
                            .includes(:buyer, :item)
                            .recent
  end
end
