# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck

  enum :difficulty, { easy: 0, medium: 1, hard: 2, again: 3 }

  validates :front,            presence: true
  validates :back,             presence: true
  validates :last_reviewed_at, presence: true, allow_nil: true
  validates :difficulty, inclusion: { in: difficulties.keys }, allow_nil: true

  before_create :initialize_spaced_repetition

  scope :due, -> { where("next_review <= ?", Date.current) }

  def review!(user)
    profile = user.profile 
    speed   = profile&.learning_speed || 1.0 

    self.efactor    ||= 2.5
    self.repetition ||= 0
    self.interval   ||= 1

    q = quality_score

    if q < 3
      self.repetition  = 0
      self.interval    = 0
      self.next_review = Time.current + 1.minute
    else
      self.repetition += 1
      self.interval   = if repetition == 1
                        case q
                        when 3 then 1
                        when 4 then 3
                        when 5 then 4
                        end
      elsif repetition == 2
        6
      else
        (interval * efactor).round
      end
      
      adjust_interval      = (interval * speed).round
      self.next_review     = Date.current + adjust_interval.days
    end

    self.efactor += (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    self.efactor  = 1.3 if efactor < 1.3

    self.last_reviewed_at = Time.current

    save!
  end

  private

  def quality_score
    case difficulty
    when "easy"   then 5
    when "medium" then 4
    when "hard"   then 3
    when "again"  then 1
    else 3
    end
  end

  def initialize_spaced_repetition
    self.efactor     ||= 2.5
    self.repetition  ||= 0
    self.interval    ||= 1
    self.next_review ||= Date.today
  end
end
