# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck

  enum :difficulty, { easy: 0, medium: 1, hard: 2, again: 3 }

  # Validações
  validates :front, :back, presence: true
  validates :difficulty, inclusion: { in: difficulties.keys }, allow_nil: true

  # Callbacks
  before_create :initialize_spaced_repetition

  # Scopes (Melhorados para legibilidade)
  scope :due, -> { where("next_review <= ?", Time.current) }
  scope :new_cards,      -> { where(repetition: 0) }
  scope :learning_cards, -> { where(repetition: 1..).where("interval < 7") }
  scope :review_cards,   -> { where("interval >= 7") }

  def review!(user)
    results = simulate_review(difficulty, user)
    
    update!(
      repetition:       results[:repetition],
      interval:         results[:interval],
      efactor:          results[:efactor],
      next_review:      results[:next_review],
      last_reviewed_at: Time.current
    )
  end

  def simulate_review(difficulty_level, user)
    speed = user.profile&.learning_speed || 1.0
    
    SpacedRepetitionService.calculate(
      difficulty_level,
      { efactor: efactor, repetition: repetition, interval: interval },
      speed
    )
  end

  def learning_state
    return :new if repetition.to_i.zero?
    interval.to_i < 7 ? :learning : :review
  end

  private

  def initialize_spaced_repetition
    self.efactor     ||= 2.5
    self.repetition  ||= 0
    self.interval    ||= 1
    self.next_review ||= Time.current
  end
end
