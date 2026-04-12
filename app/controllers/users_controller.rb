class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:edit, :update]
  
  def show
    @user_items = @user.items.order(created_at: :desc).limit(10)
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def authorize_user
    redirect_to user_path(@user), alert: "Not authorized" unless @user == current_user
  end
  
  def user_params
    params.require(:user).permit(:username, :email_address, :bio)
  end
end