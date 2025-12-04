import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentPassword", 
    "password", 
    "passwordConfirmation", 
    "username",
    "submit"
  ]

  connect() {
    this.toggleChangePasswordButton() // garante estado inicial
    this.toggleDeleteAccountButton()
  }

  toggleChangePasswordButton() {
    const filled = this.currentPasswordTarget.value.trim() !== "" &&
                   this.passwordTarget.value.trim() !== "" &&
                   this.passwordConfirmationTarget.value.trim() !== ""

    this.submitTarget.disabled = !filled
  }

  toggleDeleteAccountButton() {
    const filled = this.usernameTarget.value.trim() !== "" &&
                   this.currentPasswordTarget.value.trim() !== ""

    this.submitTarget.disabled = !filled
  }
}

