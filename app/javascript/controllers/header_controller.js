// app/javascript/controllers/header_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "mainNavContent", "profileDropdownMenu"]

  connect() {
    // Adiciona um listener global para fechar o dropdown ao clicar fora
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle("hidden");
  }

  toggleProfileDropdown(event) {
    event.stopPropagation(); // Impede o fechamento imediato
    this.profileDropdownMenuTarget.classList.toggle("hidden");
  }

  clickOutside(event) {
    if (this.hasProfileDropdownMenuTarget && !this.profileDropdownMenuTarget.contains(event.target)) {
      // Se o clique não foi dentro do dropdown e não foi no botão que o abriu
      if (event.target.closest('[data-action="click->header#toggleProfileDropdown"]') === null) {
        this.profileDropdownMenuTarget.classList.add("hidden");
      }
    }
  }
}