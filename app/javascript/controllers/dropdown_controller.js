import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu", "icon" ]

  menuIcon = `
    <line x1="4" x2="20" y1="12" y2="12"></line>
    <line x1="4" x2="20" y1="6" y2="6"></line>
    <line x1="4" x2="20" y1="18" y2="18"></line>
  ` // Ícone de Menu (☰)

  closeIcon = `
    <line x1="18" y1="6" x2="6" y2="18"></line>
    <line x1="6" y1="6" x2="18" y2="18"></line>
  ` // Ícone de Fechar (✕)

  connect() {
    this.close(); 
    
    this.boundCloseIfOutside = this.closeIfOutside.bind(this)
    document.addEventListener("click", this.boundCloseIfOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseIfOutside)
  }

  close() {
      this.menuTarget.classList.add("hidden");
      this.iconTarget.innerHTML = this.menuIcon;
      this.iconTarget.classList.remove("rotate-90");
      this.iconTarget.classList.add("rotate-0", "transition-transform");
  }
  
  toggle() {
    const isOpen = !this.menuTarget.classList.contains("hidden");
    
    if (isOpen) {
        this.close();
    } else {
        this.menuTarget.classList.remove("hidden");
        this.iconTarget.innerHTML = this.closeIcon;
        this.iconTarget.classList.add("rotate-90", "transition-transform");
        this.iconTarget.classList.remove("rotate-0");
    }
  }

  closeIfOutside(event) {
    const isMenuOpen = !this.menuTarget.classList.contains("hidden")

    if (isMenuOpen && !this.element.contains(event.target)) {
      this.close() 
    }
  }
}