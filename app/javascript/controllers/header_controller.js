import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "overlay", "profileDropdownMenu"]

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
    
    this.element.addEventListener("click", this.closeOnNavigation.bind(this))
    
    document.addEventListener("turbo:before-visit", this.closeAllMenus.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
    this.element.removeEventListener("click", this.closeOnNavigation.bind(this))
    document.removeEventListener("turbo:before-visit", this.closeAllMenus.bind(this))
  }

  closeOnNavigation(event) {
    if (event.target.tagName === 'A' || event.target.closest('a')) {
      this.closeAllMenus()
    }
  }

  closeAllMenus() {
    this.closeMobileMenu()
    if (this.hasProfileDropdownMenuTarget) {
      this.profileDropdownMenuTarget.classList.add("hidden")
    }
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
