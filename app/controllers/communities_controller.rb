class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[show update join leave]
  before_action :authorize_admin!, only: %i[update]
  allow_unauthenticated_access only: %i[index show]

  def index
    communities = Community.order(:community_type, :name)
      .select("communities.*,
        (SELECT COUNT(*) FROM items WHERE items.community_id = communities.id AND items.status = 0) AS items_count,
        (SELECT COUNT(*) FROM community_memberships WHERE community_memberships.community_id = communities.id) AS members_count")
    @communities_by_type = communities.group_by(&:community_type)
  end

  def show
    @show_sidebar = true
    @active_community_id = @community.id
    @items = @community.items.where(status: :available).order(created_at: :desc)
    @is_member = Current.user && @community.community_memberships.exists?(user: Current.user)
    @is_admin = Current.user && @community.community_memberships.exists?(user: Current.user, role: :admin)
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
    redirect_to @community, alert: "Not authorized." unless Current.user && @community.admins.include?(Current.user)
  end

  def community_params
    params.require(:community).permit(:listing_rules)
  end
end
