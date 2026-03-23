class Offers::CountersController < Offers::BaseController
  def create
    if params[:counter_price].to_f > 0
      @offer.counter!(counter_price.to_f)
      redirect_to @item, notice: "Counter-offer sent."
    else
      redirect_to @item, alert: "Counter price must be greater than zero."
    end
  end
end
