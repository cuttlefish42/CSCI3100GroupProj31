class RegistrationsController < ApplicationController
  # Rails 8 built-in authentication
  allow_unauthenticated_access only: [:new, :create]

  def new
    # @user = User.new
  end

  def create
    # Registration logic here
  end
end