import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "description"]
  static values = {
    descriptions: { type: Object, default: {} }
  }

  descriptions = {
    "4.0": "Relaxado: Repetições menos frequentes, ideal para revisões mais espaçadas e menos intensivas.",
    "9.0": "Normal: Frequência balanceada para uma aprendizagem consistente sem sobrecarga.",
    "19.0": "Rigoroso: Repetições mais frequentes para maior retenção a longo prazo.",
    "32.3": "Máximo: Frequência intensiva para memorização máxima e revisão rigorosa."
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
