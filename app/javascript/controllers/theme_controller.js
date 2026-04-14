import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    const saved = localStorage.getItem("theme") || "cuhk"
    this.applyTheme(saved)
  }

  switch() {
    const current = document.documentElement.getAttribute("data-theme")
    const next = current === "dark" ? "cuhk" : "dark"
    this.applyTheme(next)
    localStorage.setItem("theme", next)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    this.toggleTarget.checked = theme === "dark"
  }
}
