# typed: false
# frozen_string_literal: true

require "test_helper"

class FlashcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @flashcard = flashcards(:one)
    @deck      = decks(:english)
  end

  it "should get new" do
    get new_deck_flashcard_url(@deck)
    must_respond_with :success
  end

  
  it "should create flashcard" do
    assert_difference("Flashcard.count") do
      post deck_flashcards_url(@deck), params: { flashcard: { back: @flashcard.back, deck_id: @flashcard.deck_id, difficulty: @flashcard.difficulty, front: @flashcard.front, last_reviewed_at: @flashcard.last_reviewed_at } }
    end

    new_flashcard = Flashcard.last
    must_redirect_to deck_flashcard_url(@deck, Flashcard.last)
  end

  it "should show flashcard" do
    get deck_flashcard_url(@deck, @flashcard)
    must_respond_with :success
  end
end
