import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    const Chart = window.Chart
    if (!Chart) { return }

    fetch(this.urlValue)
      .then(res => res.json())
      .then(data => this.#renderChart(Chart, data))
  }

  disconnect() {
    if (this.chart) { this.chart.destroy() }
  }

  #renderChart(Chart, snapshots) {
    if (!snapshots.length) {
      this.element.parentElement.insertAdjacentHTML("beforeend",
        '<p class="text-base-content/50 text-sm text-center mt-2">No data yet</p>')
      return
    }

    const labels = snapshots.map(s => {
      const d = new Date(s.recorded_at)
      return d.toLocaleDateString(undefined, { month: "short", day: "numeric" }) +
        " " + d.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
    })

    const ctx = this.element.getContext("2d")
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Views",
            data: snapshots.map(s => s.views_count),
            borderColor: "rgb(59, 130, 246)",
            backgroundColor: "rgba(59, 130, 246, 0.1)",
            fill: true,
            tension: 0.3
          },
          {
            label: "Likes",
            data: snapshots.map(s => s.likes_count),
            borderColor: "rgb(239, 68, 68)",
            backgroundColor: "rgba(239, 68, 68, 0.1)",
            fill: true,
            tension: 0.3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: "index", intersect: false },
        scales: {
          x: { ticks: { maxTicksToSkip: 24 } },
          y: { beginAtZero: true }
        }
      }
    })
  }
}
