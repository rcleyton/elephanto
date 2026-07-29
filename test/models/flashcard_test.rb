# typed: false
# frozen_string_literal: true

require "test_helper"

describe Flashcard do
  setup do
    @deck = decks(:english)
  end

  it "is valid with front and back" do
    flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer")

    assert flashcard.valid?
  end

  it "rejects an answer containing only formatting markup" do
    flashcard = Flashcard.new(deck: @deck, front: "Question", back: "<br>")

    refute flashcard.valid?
    assert_includes flashcard.errors[:back], "não pode ficar em branco"
  end

  it "sets a default fsrs_state for new records" do
    flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer")

    assert flashcard.fsrs_state.present?
    assert_equal Fsrs::Card.new.to_h.keys.sort, flashcard.fsrs_state.deep_symbolize_keys.keys.sort
  end

  it "builds an fsrs_card even when persisted fsrs_state is nil" do
    flashcard = flashcards(:two)
    flashcard.update_column(:fsrs_state, nil)

    assert_instance_of Fsrs::Card, flashcard.fsrs_card
  end

  it "falls back safely when fsrs timestamps are invalid" do
    flashcard = Flashcard.create!(deck: @deck, front: "Question", back: "Answer")

    flashcard.update_column(:fsrs_state, flashcard.fsrs_state.merge("due" => "not-a-date", "last_review" => "still-not-a-date"))
    flashcard.reload

    assert_instance_of DateTime, flashcard.fsrs_card.due
    assert_nil flashcard.fsrs_card.last_review
  end

  it "returns relations for state scopes" do
    flashcard = Flashcard.create!(deck: @deck, front: "Question", back: "Answer")

    flashcard.update_column(:fsrs_state, flashcard.fsrs_state.merge("state" => 2))

    assert_includes Flashcard.review_state, flashcard
    refute_includes Flashcard.new_state, flashcard
  end

  it "filters due flashcards in SQL" do
    due_flashcard = Flashcard.create!(deck: @deck, front: "Due", back: "Now")
    future_flashcard = Flashcard.create!(deck: @deck, front: "Future", back: "Later")

    due_flashcard.update_column(:fsrs_state, due_flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))
    future_flashcard.update_column(:fsrs_state, future_flashcard.fsrs_state.merge("due" => 2.days.from_now.utc.iso8601))

    assert_includes Flashcard.due, due_flashcard
    refute_includes Flashcard.due, future_flashcard
  end
end
