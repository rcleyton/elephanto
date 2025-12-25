# typed: false
# frozen_string_literal: true

# app/services/spaced_repetition_service.rb
class SpacedRepetitionService
  def self.calculate(difficulty, current_data, learning_speed = 1.0)
    q = quality_score(difficulty)
    efactor = current_data[:efactor] || 2.5
    repetition = current_data[:repetition] || 0
    interval = current_data[:interval] || 1

    if q < 3
      {
        repetition: 0,
        interval: 0,
        efactor: efactor, # Mantém ou reseta conforme regra de negócio
        next_review: Time.current + 1.minute
      }
    else
      repetition += 1
      new_interval = case repetition
                     when 1 then { 3 => 1, 4 => 3, 5 => 4 }[q]
                     when 2 then 6
                     else (interval * efactor).round
                     end

      new_efactor = efactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      new_efactor = [new_efactor, 1.3].max
      
      adjusted_interval = (new_interval * learning_speed).round

      {
        repetition: repetition,
        interval: new_interval,
        efactor: new_efactor,
        next_review: Date.current + adjusted_interval.days
      }
    end
  end

  def self.quality_score(difficulty)
    { "easy" => 5, "medium" => 4, "hard" => 3, "again" => 1 }[difficulty.to_s] || 3
  end
end
