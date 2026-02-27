# typed: false
# frozen_string_literal: true

class Flashcard < ApplicationRecord
  belongs_to :deck
  validates :front, :back, presence: true

  after_initialize :set_default_fsrs_state, if: :new_record?

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
