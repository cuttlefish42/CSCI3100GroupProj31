import { Controller } from "@hotwired/stimulus"

// Quick-calc buttons for offer price fields.
// Set data-offer-price-listing-value to the item's listing price.
export default class extends Controller {
  static targets = ["input"]
  static values = { listing: Number }

  adjust(event) {
    const pct = parseFloat(event.currentTarget.dataset.pct)
    const price = (this.listingValue * pct).toFixed(2)
    this.inputTarget.value = price
    this.inputTarget.focus()
  }
}
