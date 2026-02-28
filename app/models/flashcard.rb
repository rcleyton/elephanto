# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck
  validates :front, :back, presence: true

  after_initialize :set_default_fsrs_state, if: :new_record?

  scope :new_state,        -> { where("fsrs_state->>'state' = '0'").count }
  scope :learning_state,   -> { where("fsrs_state->>'state' = '1'").count }
  scope :review_state,     -> { where("fsrs_state->>'state' = '2'").count }
  scope :relearning_state, -> { where("fsrs_state->>'state' = '3'").count }

  scope :due, -> {
    now_str = Time.current.utc.iso8601
    where(
      "(fsrs_state->>'due' LIKE '-%') OR (fsrs_state->>'due' <= ?)",
      now_str
    )
  }

  def fsrs_card
    data = fsrs_state.deep_symbolize_keys

    data[:due] = ensure_time(data[:due])
    data[:last_review] = ensure_time(data[:last_review])

    Fsrs::Card.from_h(data)
  end

  def due?
    fsrs_card.due <= Time.current
  end

  def rate!(rating)
    rating_int = rating.to_i
    scheduler  = Fsrs::Scheduler.new
    scheduling = scheduler.repeat(fsrs_card, Time.current.utc)
    info       = scheduling[rating_int]

    raise "Rating inválido: #{rating_int}" unless info

    update!(fsrs_state: info.card.to_h)
  end

  def review_options
    scheduler        = Fsrs::Scheduler.new
    scheduling_cards = scheduler.repeat(fsrs_card, Time.current.utc)

    {
      again: scheduling_cards[Fsrs::Rating::AGAIN].card,
      hard:  scheduling_cards[Fsrs::Rating::HARD].card,
      good:  scheduling_cards[Fsrs::Rating::GOOD].card,
      easy:  scheduling_cards[Fsrs::Rating::EASY].card
    }
  end

  private

  def ensure_time(value)
    return nil if value.blank?
    return value if value.is_a?(Time)

    value.is_a?(String) ? Time.zone.parse(value).utc : value.to_time.utc
  rescue
    Time.current.utc
  end

  def set_default_fsrs_state
    self.fsrs_state ||= Fsrs::Card.new.to_h
  end
end
