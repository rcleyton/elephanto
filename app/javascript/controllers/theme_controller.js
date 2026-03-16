import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  toggle() {
    const html = document.documentElement

    html.classList.toggle("dark")

    const theme = html.classList.contains("dark") ? "dark" : "light"
    localStorage.setItem("theme", theme)

    this.updateIcon()
  }

  connect() {
    this.updateIcon()
  }

  updateIcon() {
    const isDark = document.documentElement.classList.contains("dark")

    this.iconTarget.textContent = isDark ? "dark_mode" : "light_mode"
  }
}
