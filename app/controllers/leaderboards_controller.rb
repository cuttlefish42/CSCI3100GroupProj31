class LeaderboardsController < ApplicationController
  def karma
    @sort = params[:sort] || "highest"

    if @sort == "lowest"
      @users = User.order(karma: :asc)
      chart_users = User.order(karma: :asc).limit(20)
    else
      @users = User.order(karma: :desc)
      chart_users = User.order(karma: :desc).limit(20)
    end

    @display_users = @users.limit(20)

    # chart
    @labels = chart_users.map(&:username).to_json
    @values = chart_users.map(&:karma).to_json
  end
end
