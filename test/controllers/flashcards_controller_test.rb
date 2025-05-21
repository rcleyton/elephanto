# typed: false
# frozen_string_literal: true

require "test_helper"

class FlashcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck      = decks(:english)
    @flashcard = @deck.flashcards.create(front: "Question", back: "Answer", difficulty: "easy")
  end

  it "should get new" do
    get new_deck_flashcard_url(@deck)
    must_respond_with :success
  end

  it "should show flashcard" do
    get deck_flashcard_url(@deck, Flashcard.last)
    must_respond_with :success
  end

  context "create" do
    it "should create flashcard" do
      assert_difference("Flashcard.count") do
        post deck_flashcards_url(@deck), params: { flashcard: { back: @flashcard.back, difficulty: @flashcard.difficulty, front: @flashcard.front, last_reviewed_at: @flashcard.last_reviewed_at } }
      end
      
      must_redirect_to new_deck_flashcard_url(@deck)
    end

    it "front cannot be empty" do
      post deck_flashcards_url(@deck), params: { flashcard: { back: @flashcard.back, front: "" } }

      assert_response :unprocessable_entity
      assert_template :new
    end

    it "back cannot be empty" do
      post deck_flashcards_url(@deck), params: { flashcard: { back: "", front: @flashcard.front } }

      assert_response :unprocessable_entity
      assert_template :new
    end

    it "difficult can be blank" do
      assert_difference("Flashcard.count") do
        post deck_flashcards_url(@deck), params: { flashcard: { back: @flashcard.back, front: @flashcard.front, difficulty: "" } }
      end

      must_redirect_to new_deck_flashcard_url(@deck)
    end
  end
end
