# typed: false
# frozen_string_literal: true

require "test_helper"

describe Flashcard do
  setup do
    @deck = decks(:english)
  end

  describe "difficulties" do
    it "accepts valid difficulties" do
      valid_difficulties = ["again", "easy", "medium", "hard", "", nil]

      valid_difficulties.each do |difficulty|
        flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer", difficulty: difficulty)
        expect(flashcard.valid?).must_equal true
      end
    end
  end
end