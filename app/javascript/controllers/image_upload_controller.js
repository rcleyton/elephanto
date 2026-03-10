import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["input", "preview"]

  previewImage(event) {

    const input = event.target
    const file = input.files[0]

    if (!file) return

    const url = URL.createObjectURL(file)

    if (this.previewTarget.tagName === "IMG") {
      this.previewTarget.src = url
    }

    input.form.requestSubmit()
  }
}
