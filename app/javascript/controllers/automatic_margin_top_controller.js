import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.adjustMargin();
    }, 50);

    this.resizeHandler = this.debounce(this.adjustMargin.bind(this), 100);
    window.addEventListener('resize', this.resizeHandler);
  }

  disconnect() {
    if (this.resizeHandler) {
      window.removeEventListener('resize', this.resizeHandler);
    }
  }

  adjustMargin() {
    const header = document.querySelector('header');

    if (!header) {
      return;
    }

    const headerStyle = window.getComputedStyle(header);
    const headerPosition = headerStyle.getPropertyValue('position');
    const headerHeight = header.offsetHeight;

    if (headerPosition === 'fixed') {
      this.element.style.marginTop = `${headerHeight}px`;
    } else {
      this.element.style.marginTop = '0';
    }
  }

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}