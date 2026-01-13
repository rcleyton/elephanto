# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck

  enum :difficulty, { easy: 0, medium: 1, hard: 2, again: 3 }

  validates :front, :back, presence: true
  validates :difficulty, inclusion: { in: difficulties.keys }, allow_nil: true

  before_create :initialize_spaced_repetition

  scope :due, -> { where("next_review <= ?", Time.current) }
  scope :new_cards,      -> { where(repetition: 0) }
  scope :learning_cards, -> { where(repetition: 1..).where("interval < 7") }
  scope :review_cards,   -> { where("interval >= 7") }

  def review!(user_difficulty, user)
    rigor = user.profile&.rigor_factor || 9.0

    results = SpacedRepetitionService.calculate(
      user_difficulty,
      {
        stability:        stability,
        difficulty_score: difficulty_score,
        last_reviewed_at: last_reviewed_at,
        repetition:       repetition,
        interval:         interval
      },
      rigor
    )

    update!(
      difficulty:       user_difficulty,
      stability:        results[:stability],
      difficulty_score: results[:difficulty_score],
      interval:         results[:interval],
      next_review:      results[:next_review],
      last_reviewed_at: Time.current,
      repetition:       user_difficulty.to_s == "again" ? 0 : (repetition + 1)
    )
  end

  private

  def initialize_spaced_repetition
    self.stability        ||= 0.1
    self.difficulty_score ||= 5.0
    self.repetition       ||= 0
    self.interval         ||= 0
    self.next_review      ||= Time.current
  end
end
