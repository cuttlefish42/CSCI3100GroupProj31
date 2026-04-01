import { Controller } from "@hotwired/stimulus"

// Popup modal with quick-calc buttons for offer price fields.
// data-offer-price-base-value: the base price for quick-set calculations
//   - For "Make an Offer": the item listing price
//   - For "Edit Your Offer": the current offer price
export default class extends Controller {
  static targets = ["modal", "input"]
  static values = { base: Number }

  open() {
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }

  adjust(event) {
    const pct = parseFloat(event.currentTarget.dataset.pct)
    const price = (this.baseValue * pct).toFixed(2)
    this.inputTarget.value = price
    this.inputTarget.focus()
  }
}
