class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[show update]
  before_action :authorize_admin!, only: %i[update]
  allow_unauthenticated_access only: %i[index show]

  def index
    @communities_by_type = Community.grouped_by_type
  end

  def show
    @show_sidebar = true
    @active_community_id = @community.id
    @items = @community.items.where(status: :available).order(created_at: :desc)
    @is_admin = Current.user && @community.admins.include?(Current.user)
  end

  def update
    if @community.update(community_params)
      redirect_to @community, notice: "Listing rules updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_community
    @community = Community.find(params[:id])
  end

  def authorize_admin!
    redirect_to @community, alert: "Not authorized." unless Current.user && @community.admins.include?(Current.user)
  end

  def community_params
    params.require(:community).permit(:listing_rules)
  end
end
