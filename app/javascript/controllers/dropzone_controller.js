// app/javascript/controllers/dropzone_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropArea", "input", "preview"]

  connect() {
    this.dropAreaTarget.addEventListener("click", () => this.inputTarget.click())
    this.dropAreaTarget.addEventListener("dragover", e => e.preventDefault())
    this.dropAreaTarget.addEventListener("drop", this.handleDrop.bind(this))
    this.inputTarget.addEventListener("change", this.handleFileSelect.bind(this))
  }

  handleDrop(event) {
    event.preventDefault()
    const files = event.dataTransfer.files
    if (files.length) {
      this.inputTarget.files = files
      this.handleFileSelect()
    }
  }

  handleFileSelect() {
    const file = this.inputTarget.files[0]
    if (!file) return

    // Type validade
    const validTypes = ["image/jpeg", "image/png", "image/webp"]
    if (!validTypes.includes(file.type)) {
      alert("Formato inválido. Use JPG, PNG ou WEBP.")
      this.inputTarget.value = ""
      return
    }

    // Size validate (2MB)
    const maxSize = 2 * 1024 * 1024
    if (file.size > maxSize) {
      alert("Imagem muito grande. Limite de 2MB.")
      this.inputTarget.value = ""
      return
    }

    // Image preview
    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewTarget.src = e.target.result
      this.previewTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }
}
