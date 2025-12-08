import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["profileDropdownMenu"]

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)

    document.addEventListener("turbo:before-cache", () => {
      if (this.hasProfileDropdownMenuTarget) {
        this.profileDropdownMenuTarget.classList.add("hidden")
      }
    })
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggleProfileDropdown(event) {
    event.stopPropagation();

    const menu = this.profileDropdownMenuTarget;

    if (menu.classList.contains("hidden")) {
      menu.classList.remove("hidden", "pointer-events-none", "animate-dropdownOut");
      menu.classList.add("animate-dropdownIn");
    } else {
      menu.classList.remove("animate-dropdownIn");
      menu.classList.add("animate-dropdownOut");

      setTimeout(() => {
        menu.classList.add("hidden", "pointer-events-none");
      }, 150);
    }
  }

  clickOutside(event) {
    if (!this.hasProfileDropdownMenuTarget) return

    const menu = this.profileDropdownMenuTarget

    const clickInsideMenu = menu.contains(event.target)

    const clickedToggleButton =
      event.target.closest('[data-action="header#toggleProfileDropdown"]')

    if (!clickInsideMenu && !clickedToggleButton) {
      menu.classList.add("hidden")
    }
  }
}
