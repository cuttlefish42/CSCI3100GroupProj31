import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    type:   String,
    labels: String, // x axis labels
    data:   String,
    label:  String  // legend
  }

  connect() {
    this.chart = new Chart(this.element, {
      type: this.typeValue || "bar",
      data: {
        labels: this.labelsValue,
        datasets: [{
          label:              this.labelValue || "Data",
          data:               this.dataValue,
          borderwidth:        1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    })
  }
  disconnect() {
    this.chart?.destroy()
  }
}
