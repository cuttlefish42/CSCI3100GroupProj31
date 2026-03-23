class Offers::AcceptancesController < Offers::BaseController
  def create
    @offer.accept!
    redirect_to @item, notice: "Offer accepted. Item is now reserved."
  end

  def update
      redirect_to @item, alert: "Invalid status."
  end
end
