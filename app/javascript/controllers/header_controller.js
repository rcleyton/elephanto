import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "overlay", "profileDropdownMenu"]

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggleMobileMenu() {
    const isOpen = !this.mobileMenuTarget.classList.contains("translate-x-full")

    if (isOpen) {
      this.closeMobileMenu()
    } else {
      this.openMobileMenu()
    }
  }

  openMobileMenu() {
    this.mobileMenuTarget.classList.remove("translate-x-full")
    this.overlayTarget.classList.remove("hidden")
  }

  closeMobileMenu() {
    this.mobileMenuTarget.classList.add("translate-x-full")
    this.overlayTarget.classList.add("hidden")
  }

  toggleProfileDropdown(event) {
    event.stopPropagation()
    this.profileDropdownMenuTarget.classList.toggle("hidden")
  }

  clickOutside(event) {
    if (this.hasProfileDropdownMenuTarget && !this.profileDropdownMenuTarget.contains(event.target)) {
      if (event.target.closest('[data-action="click->header#toggleProfileDropdown"]') === null) {
        this.profileDropdownMenuTarget.classList.add("hidden")
      }
    }
  }
}