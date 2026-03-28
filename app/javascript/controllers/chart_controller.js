import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    type:   String,
    labels: String,
    data:   String,
    label:  String
  }

  connect() {
    console.log("Chart controller connected");
    
    // Get Chart from window (UMD module)
    const Chart = window.Chart;
    if (!Chart) {
      console.error("Chart.js not loaded");
      return;
    }
    
    let labels = [];
    let data = [];

    try {
      const labelsStr = this.labelsValue || "[]";
      const dataStr = this.dataValue || "[]";
      
      console.log("Raw labels:", labelsStr);
      console.log("Raw data:", dataStr);
      
      labels = JSON.parse(labelsStr);
      data = JSON.parse(dataStr);
      
      console.log("Parsed labels:", labels);
      console.log("Parsed data:", data);
    } catch (e) {
      console.error("Failed to parse chart data:", e);
      return;
    }

    if (!this.element) {
      console.error("Canvas element not found");
      return;
    }

    console.log("Canvas element:", this.element);
    
    const ctx = this.element.getContext("2d");
    if (!ctx) {
      console.error("Failed to get 2D context from canvas");
      return;
    }

    console.log("Creating chart with labels:", labels, "data:", data);

    this.chart = new Chart(ctx, {
      type: this.typeValue || "bar",
      data: {
        labels: labels,
        datasets: [{
          label: this.labelValue || "Karma",
          data: data,
          backgroundColor: "rgba(75, 192, 192, 0.6)",
          borderColor: "rgba(75, 192, 192, 1)",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true
          }
        },
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });

    console.log("Chart created successfully:", this.chart);
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy();
    }
  }
}
