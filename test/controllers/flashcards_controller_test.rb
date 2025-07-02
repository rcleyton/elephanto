# typed: false
# frozen_string_literal: true

require "test_helper"

class FlashcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck       = decks(:english)
    @flashcard  = @deck.flashcards.create(front: "Question",  back: "Answer", difficulty: "easy")
    @flashcard2 = @deck.flashcards.create(front: "Question2", back: "Answer2")
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

  context "review flashcards" do
    it "should review flashcard and redirect to next one" do
      post review_deck_flashcard_path(@deck, @flashcard), params: { difficulty: "easy" }

      @flashcard.reload
      assert_not_nil @flashcard.last_reviewed_at
      assert_equal "easy", @flashcard.difficulty

      assert_redirected_to deck_flashcard_path(@deck, @flashcard2)
    end

    it "should redirect to deck when no next flashcard" do
      @flashcard.update!(
        next_review: 1.day.from_now,
        last_reviewed_at: Time.current,
        difficulty: "easy"
      )

      @flashcard2.update!(
        next_review: Time.current,
        last_reviewed_at: nil,
        difficulty: nil
      )

      post review_deck_flashcard_path(@deck, @flashcard2), params: { difficulty: "medium" }

      @flashcard2.reload
      assert_not_nil @flashcard2.last_reviewed_at
      assert_equal "medium", @flashcard2.difficulty

      assert_redirected_to deck_path(@deck)
      follow_redirect!
      assert_match I18n.t("messages.completed_review"), response.body
    end
  end
end
