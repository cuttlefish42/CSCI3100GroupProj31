class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy toggle_like analytics ]
  before_action :authorize_owner!, only: %i[ edit update destroy analytics ]
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @show_sidebar = true
    @items = Item.where(status: :available).order(created_at: :desc)
    if params[:community_id].present?
      @items = @items.where(community_id: params[:community_id])
      @active_community_id = params[:community_id].to_i
    end
  end

  def show
    @item.increment!(:views_count)
    @offer_sort = params[:offer_sort] || "date"
    @offer_dir = params[:offer_dir] || "desc"
    @offers = @item.offers.includes(:buyer)
    .sorted_by(@offer_sort, @offer_dir, context: :received)
    @existing_offer = Current.user ? @item.offers.by_buyer(Current.user).active.first : nil
    @liked = Current.user ? @item.likes.exists?(user_id: Current.user.id) : false
    @offer = @item.offers.build
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def create
    @item = Item.new(item_params)
    @item.seller = Current.user

    if @item.save
      redirect_to @item, notice: "Item created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_like
    like = @item.likes.find_by(user_id: Current.user.id)
    if like
      like.destroy
    else
      @item.likes.create!(user_id: Current.user.id)
    end
    @item.reload
    render partial: "items/like_button", locals: { item: @item }
  end

  def analytics
    from = params[:from] ? Time.zone.parse(params[:from]) : 7.days.ago
    to = params[:to] ? Time.zone.parse(params[:to]) : Time.current

    snapshots = @item.item_snapshots.between(from, to).order(:recorded_at)

    render json: snapshots.map { |s|
      {
        recorded_at: s.recorded_at.iso8601,
        views_count: s.views_count,
        likes_count: s.likes_count
      }
    }
  end

  def destroy
    @item.destroy!
    redirect_to items_path, status: :see_other, notice: "Item destroyed."
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def authorize_owner!
      return if @item.seller == Current.user
      return if @item.community && @item.community.admins.include?(Current.user)
      redirect_to items_path, alert: "Not authorized."
    end

    def item_params
      params.expect(item: [ :title, :description, :price, :condition, :status, :category_id, :community_id, :photo, :latitude, :longitude, :meetup_note ])
    end
end
