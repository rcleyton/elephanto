import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "description"]

  descriptions = {
    "32.3": "Relaxado: Repetições menos frequentes, ideal para quem tem muitos cards e pouco tempo.",
    "9.0":  "Normal: Frequência balanceada para uma retenção de aproximadamente 90%.",
    "4.0":  "Rigoroso: Repetições frequentes para garantir que você quase nunca esqueça (95%).",
    "2.5":  "Máximo: Frequência intensiva. Ideal para conteúdos críticos onde o erro não é uma opção."
  }

  connect() {
    this.updateDescription()
  }

  updateDescription() {
    const selectedValue = this.selectTarget.value
    const description = this.descriptions[selectedValue] || "Selecione uma opção para ver a descrição"
    
    this.descriptionTarget.textContent = description
  }
}
