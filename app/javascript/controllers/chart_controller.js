import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  connect() {
    // this.chart = new Chart()
  }
  disconnect() {
    this.chart?.destroy()
  }
}
