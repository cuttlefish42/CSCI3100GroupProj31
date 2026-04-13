class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[show update join leave]
  before_action :authorize_admin!, only: %i[update]
  allow_unauthenticated_access only: %i[index show]

  def index
    @communities_by_type = Community.grouped_by_type_with_counts
  end

  def show
    @show_sidebar = true
    @active_community_id = @community.id
    @items = @community.items.where(status: :available).order(created_at: :desc)
    @is_member = Current.user && @community.member?(Current.user)
    @is_admin = Current.user && @community.admin?(Current.user)
  end

  def join
    @community.community_memberships.find_or_create_by!(user: Current.user) do |m|
      m.role = :member
    end
    redirect_to @community, notice: "Joined #{@community.name}."
  end

  def leave
    membership = @community.community_memberships.find_by(user: Current.user)
    if membership&.admin?
      redirect_to @community, alert: "Admins cannot leave their community."
    else
      membership&.destroy
      redirect_to @community, notice: "Left #{@community.name}."
    end
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
    redirect_to @community, alert: "Not authorized." unless Current.user && @community.admin?(Current.user)
  end

  def community_params
    params.require(:community).permit(:listing_rules)
  end
end
