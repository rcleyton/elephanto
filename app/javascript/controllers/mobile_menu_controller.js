import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "overlay"]

  connect() {
    document.addEventListener("turbo:before-cache", () => {
      if (this.hasMobileMenuTarget) {
        this.mobileMenuTarget.classList.add("translate-x-full")
      }
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
    })
  }

  toggleMobileMenu() {
    const isOpen = !this.mobileMenuTarget.classList.contains("translate-x-full")

    if (isOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    this.mobileMenuTarget.classList.remove("translate-x-full");
    this.overlayTarget.classList.remove("hidden", "pointer-events-none");

    requestAnimationFrame(() => {
      this.overlayTarget.classList.add("opacity-100");
    });
  }

  closeMenu() {
    this.mobileMenuTarget.classList.add("translate-x-full");

    this.overlayTarget.classList.remove("opacity-100");
    this.overlayTarget.classList.add("opacity-0");

    setTimeout(() => {
      this.overlayTarget.classList.add("hidden", "pointer-events-none");
    }, 300);
  }
}

