# typed: false
# frozen_string_literal: true

class SpacedRepetitionService
  W = [ 0.4, 0.6, 2.4, 5.8, 4.93, 0.94, 0.86, 0.01, 1.49, 0.14, 0.94, 2.18, 0.05, 0.34, 1.26, 0.29, 2.61 ]

  def self.calculate(difficulty_input, current_data, rigor_factor = 9.0)
    rigor_factor = rigor_factor.to_f
    grade        = quality_score(difficulty_input)
    s            = current_data[:stability].to_f
    d            = current_data[:difficulty_score]
    last_review  = current_data[:last_reviewed_at]

    # --- CASO 1: PRIMEIRA REVISÃO (Cartão Novo) ---
    if last_review.nil? || current_data[:repetition].to_i == 0
      new_s = W[grade - 1]
      new_d = 10.1 - W[4] * (grade - 1)

      # Para o "Again" em cartão novo, forçamos revisão no mesmo dia
      if grade == 1
        interval = 0
        next_review = Time.current + 5.minutes
      else
        interval = (new_s * rigor_factor).round
        interval = [ interval, (current_data[:interval].to_i + 1) ].max # Garante pelo menos 1 dia para Hard/Medium/Easy
        next_review = Date.current + interval.days
      end

      return {
        stability: new_s,
        difficulty_score: new_d.clamp(1, 10),
        interval: interval,
        next_review: next_review
      }
    end

    # --- CASO 2: REVISÕES SUBSEQUENTES ---
    days_since_last = (Date.current - last_review.to_date).to_i
    # Se revisou hoje (mesmo dia), tratamos como 0 para não inflar a estabilidade
    days_since_last = [ days_since_last, 0 ].max
    retrievability  = (1 + days_since_last / (rigor_factor * s))**-1

    if grade == 1 # Errou (Again)
      new_s = [ s * 0.2, 0.1 ].max # Reduz estabilidade drasticamente
      new_d = [ d + 1.0, 10.0 ].min # Aumenta dificuldade
      interval = 0
      next_review = Time.current + 5.minutes
    else
      # Acertou: Ajusta Dificuldade
      new_d = d + (grade - 3) * -0.5
      new_d = new_d.clamp(1, 10)

      # Ajusta Estabilidade usando a fórmula de reforço do SM-17/FSRS
      growth_factor = (Math.exp(W[8]) * (11 - new_d) * (s**-W[9]) * (Math.exp((1 - retrievability) * W[10]) - 1))

      grade_bonus = { 2 => 0.7, 3 => 1.0, 4 => 1.3 }[grade] || 1.0
      new_s = s * (1 + growth_factor * grade_bonus)

      interval = (new_s * rigor_factor).round
      interval = [ interval, current_data[:interval] + 1 ].max # Garante que o intervalo sempre cresce se acertar
      next_review = Date.current + interval.days
    end

    {
      stability: new_s.round(4),
      difficulty_score: new_d.round(4),
      interval: interval,
      next_review: next_review
    }
  end

  def self.quality_score(difficulty)
    scores = {
      "again"  => 1,
      "hard"   => 2,
      "medium" => 3,
      "easy"   => 4
    }
    scores[difficulty.to_s] || 3
  end
end
