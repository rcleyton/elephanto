import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentPassword", "password", "passwordConfirmation", "submit"]

  connect() {
    this.toggleButton() // garante estado inicial
  }

  toggleButton() {
    const filled = this.currentPasswordTarget.value.trim() !== "" &&
                   this.passwordTarget.value.trim() !== "" &&
                   this.passwordConfirmationTarget.value.trim() !== ""

    this.submitTarget.disabled = !filled
  }
}

