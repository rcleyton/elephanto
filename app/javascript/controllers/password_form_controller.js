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
    this.toggleChangePasswordButton()
    this.toggleDeleteAccountButton()
  }

  toggleChangePasswordButton() {
    if (!(this.hasCurrentPasswordTarget &&
          this.hasPasswordTarget &&
          this.hasPasswordConfirmationTarget)) {
      return
    }

    const filled =
      this.currentPasswordTarget.value.trim() !== "" &&
      this.passwordTarget.value.trim() !== "" &&
      this.passwordConfirmationTarget.value.trim() !== ""

    this.submitTarget.disabled = !filled
  }

  toggleDeleteAccountButton() {
    if (!(this.hasUsernameTarget && this.hasCurrentPasswordTarget)) {
      return
    }

    const filled =
      this.usernameTarget.value.trim() !== "" &&
      this.currentPasswordTarget.value.trim() !== ""

    this.submitTarget.disabled = !filled
  }
}


