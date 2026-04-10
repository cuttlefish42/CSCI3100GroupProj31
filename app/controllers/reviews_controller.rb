class ReviewsController < ApplicationController
  before_action :set_offer
  before_action :authorize_reviewer!
  before_action :prevent_duplicate_review!

  def new
    @review = @offer.reviews.build(
      reviewer: Current.user,
      reviewee: counterparty,
      role: role_for_current_user
    )
  end

  def create
    @review = @offer.reviews.build(review_params)
    @review.reviewer = Current.user
    @review.reviewee = counterparty
    @review.role     = role_for_current_user

    if @review.save
      redirect_to dashboard_path,
                  notice: "Review submitted. #{counterparty_label}'s karma updated."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_offer
    @item  = Item.find(params[:item_id])
    @offer = @item.offers.find(params[:offer_id])
  end

  def authorize_reviewer!
    unless @offer.accepted? &&
           [ @offer.buyer_id, @item.seller_id ].include?(Current.user.id)
      redirect_to dashboard_path, alert: "You cannot review this transaction."
    end
  end

  def prevent_duplicate_review!
    if @offer.reviews.exists?(role: role_for_current_user)
      redirect_to dashboard_path, alert: "You have already reviewed this transaction."
    end
  end

  def counterparty
    Current.user.id == @offer.buyer_id ? @item.seller : @offer.buyer
  end

  def counterparty_label
    Current.user.id == @offer.buyer_id ? "Seller" : "Buyer"
  end

  def role_for_current_user
    Current.user.id == @offer.buyer_id ? :seller_review : :buyer_review
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end