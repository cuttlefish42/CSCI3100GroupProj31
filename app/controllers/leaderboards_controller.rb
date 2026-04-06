class LeaderboardsController < ApplicationController
  def karma
    @sort = params[:sort] || "highest"
    
    if @sort == "lowest"
      @users = User.order(karma: :asc)
      chart_users = User.order(karma: :asc).limit(10)
    else
      @users = User.order(karma: :desc)
      chart_users = User.order(karma: :desc).limit(10)
    end

    # chart
    @labels = chart_users.map(&:username).to_json
    @values = chart_users.map(&:karma).to_json
  end
end
