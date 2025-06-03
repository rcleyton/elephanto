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

  describe "last reviewed at" do
    it "can be blank" do
      flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer", difficulty: "easy", last_reviewed_at: "")
      expect(flashcard.valid?).must_equal true
    end

    it "can be nil" do
      flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer", difficulty: "easy", last_reviewed_at: nil)
      expect(flashcard.valid?).must_equal true
    end
    
    it "must be valid" do
      flashcard = Flashcard.new(deck: @deck, front: "Question", back: "Answer", difficulty: "easy", last_reviewed_at: Time.now - 5)
      expect(flashcard.valid?).must_equal true
    end
  end
end