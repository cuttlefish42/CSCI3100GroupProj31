class LeaderboardsController < ApplicationController
  def karma
    @users = User.order(karma: :desc)

    # chart
    top_users = User.order(karma: :desc).limit(10)
    @labels = top_users.map(&:username).to_json
    @values = top_users.map(&:karma).to_json
  end
end
