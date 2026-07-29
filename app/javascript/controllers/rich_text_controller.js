import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "editor", "input" ]

  connect() {
    this.editorTarget.innerHTML = this.inputTarget.value
  }

  rememberSelection() {
    const selection = window.getSelection()

    if (selection.rangeCount && this.editorTarget.contains(selection.anchorNode)) {
      this.selectionRange = selection.getRangeAt(0)
    }
  }

  format(event) {
    event.preventDefault()

    if (this.selectionRange) {
      const selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(this.selectionRange)
    }

    this.editorTarget.focus()
    document.execCommand(event.currentTarget.dataset.command, false, null)
    this.rememberSelection()
    this.sync()
  }

  sync() {
    const text = this.editorTarget.textContent.replace(/[\s\u200B]+/g, "")

    this.inputTarget.value = text ? this.editorTarget.innerHTML : ""
  }
}
