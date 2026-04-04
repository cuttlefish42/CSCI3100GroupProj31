class DashboardsController < ApplicationController
  def show
    @sent_sort = params[:sent_sort] || "date"
    @sent_dir = params[:sent_dir] == "asc" ? :asc : :desc
    @recv_sort = params[:recv_sort] || "date"
    @recv_dir = params[:recv_dir] == "asc" ? :asc : :desc

    @sent_offers = 
      Current.user.offers
        .includes(item: :seller)
        .where.not(status: "accepted")
        .sorted_by(@sent_sort, @sent_dir, scope: :sent)

    @received_offers = 
      Offer.received_by(Current.user)
        .includes(:buyer, :item)
        .where.not(status: "accepted")
        .sorted_by(@recv_sort, @recv_dir, scope: :received)
    
    @pending_transactions = 
      Offer.includes(:item, :buyer)
        .joins(:item)
        .where(status: "accepted")
        .where(
          Offer.arel_table[:buyer_id].eq(Current.user.id)
            .or(Item.arel_table[:seller_id].eq(Current.user.id))
        )
  end
end
