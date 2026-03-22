class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]
  before_action :authorize_owner!, only: %i[ edit update destroy ]
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @items = Item.all.order(created_at: :desc)
  end

  def show
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

  def destroy
    @item.destroy!
    redirect_to items_path, status: :see_other, notice: "Item destroyed."
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def authorize_owner!
      redirect_to items_path, alert: "Not authorized." unless @item.seller == Current.user
    end

    def item_params
      params.expect(item: [ :title, :price, :condition, :status, :category_id, :community_id ])
    end
end
