class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    redirect_to items_path if authenticated?
    @featured_items = Item.where(status: :available).order(created_at: :desc).limit(6)
  end
end
