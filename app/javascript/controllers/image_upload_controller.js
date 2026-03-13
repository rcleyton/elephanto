import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]
  static values = { autosave: Boolean }

  previewImage(event) {
    const input = event.target
    const file = input.files[0]

    if (!file) return

    const url = URL.createObjectURL(file)

    // pega o preview dentro do mesmo label
    const container = input.closest("label")
    const preview = container.querySelector('[data-image-upload-target="preview"]')

    if (!preview) return

    if (preview.tagName === "IMG") {
      preview.src = url
    } else {
      preview.innerHTML = `<img src="${url}" class="w-full h-full object-cover rounded-full">`
    }

    if (this.autosaveValue) {
      input.form.requestSubmit()
    }
  }
}
