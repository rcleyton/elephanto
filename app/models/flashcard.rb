# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck
  validates :front, :back, presence: true

  after_initialize :set_default_fsrs_state, if: :new_record?
  before_validation :set_default_fsrs_state

  scope :new_state,        -> { where("fsrs_state->>'state' = ?", "0") }
  scope :learning_state,   -> { where("fsrs_state->>'state' = ?", "1") }
  scope :review_state,     -> { where("fsrs_state->>'state' = ?", "2") }
  scope :relearning_state, -> { where("fsrs_state->>'state' = ?", "3") }

  scope :due, -> {
    now_str = Time.current.utc.iso8601
    where(
      "(COALESCE(fsrs_state->>'due', '') = '') OR (fsrs_state->>'due' LIKE '-%') OR (fsrs_state->>'due' <= ?)",
      now_str
    )
  }

  scope :created_this_week, -> {
    where(created_at: Time.current.beginning_of_week(:sunday)..Time.current.end_of_week(:sunday))
  }

  def fsrs_card
    signature = fsrs_state.to_json
    return @fsrs_card if @fsrs_card_signature == signature

    data = normalized_fsrs_state

    @fsrs_card = Fsrs::Card.from_h(data)
    @fsrs_card_signature = signature
    @fsrs_card
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
    reset_fsrs_card_cache
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

  def normalized_fsrs_state
    defaults = default_fsrs_state
    data = defaults.merge((fsrs_state || {}).deep_symbolize_keys)

    data[:due] = parse_fsrs_time(data[:due], field_name: :due, fallback: defaults[:due])
    data[:last_review] = parse_fsrs_time(data[:last_review], field_name: :last_review, fallback: defaults[:last_review], allow_nil: true)
    data
  end

  def parse_fsrs_time(value, field_name:, fallback:, allow_nil: false)
    return nil if allow_nil && value.blank?
    return fallback if value.blank?
    return value.utc if value.is_a?(Time)

    if value.is_a?(String)
      parsed_value = Time.zone.parse(value)
      raise ArgumentError, "invalid time value" if parsed_value.nil?

      return parsed_value.utc
    end

    value.to_time.utc
  rescue ArgumentError, NoMethodError, TypeError => error
    Rails.logger.warn("Invalid FSRS #{field_name} for Flashcard #{id || 'new'}: #{error.message}")
    fallback
  end

  def default_fsrs_state
    @default_fsrs_state ||= Fsrs::Card.new.to_h.deep_symbolize_keys
  end

  def reset_fsrs_card_cache
    @fsrs_card = nil
    @fsrs_card_signature = nil
  end

  def set_default_fsrs_state
    self.fsrs_state ||= default_fsrs_state
    reset_fsrs_card_cache
  end
end
