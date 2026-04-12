import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    const saved = localStorage.getItem("theme") || "light"
    this.applyTheme(saved)
  }

  switch() {
    const current = document.documentElement.getAttribute("data-theme")
    const next = current === "dark" ? "light" : "dark"
    this.applyTheme(next)
    localStorage.setItem("theme", next)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    this.toggleTarget.checked = theme === "dark"
  }
}
