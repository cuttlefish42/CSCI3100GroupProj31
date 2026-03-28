class LeaderboardsController < ApplicationController
  def karma
    @users = User.order(karma: :desc)
  end
end
