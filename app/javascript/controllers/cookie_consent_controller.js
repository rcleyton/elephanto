import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  connect() {
    if (localStorage.getItem("cookie_consent") === "accepted") {
      this.hide()
    } else {
      this.show()
    }
  }

  accept() {
    localStorage.setItem("cookie_consent", "accepted")
    this.hide()
  }

  show() {
    this.bannerTarget.classList.remove("hidden")
  }

  hide() {
    this.bannerTarget.classList.add("hidden")
  }
}

