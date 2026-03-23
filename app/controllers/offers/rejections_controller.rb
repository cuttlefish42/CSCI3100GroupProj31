class Offers::RejectionsController < Offers::BaseController
  def create
    @offer.rejected!
    redirect_to @item, notice: "Offer rejected."
  end
end
