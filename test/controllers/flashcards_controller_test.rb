# typed: false
# frozen_string_literal: true

require "test_helper"

class FlashcardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @deck = @user.decks.create!(name: "Deck de teste #{SecureRandom.hex(4)}", description: "Deck isolado para testes", tag: "Teste")

    post session_url, params: { email_address: @user.email_address, password: "P@ssword1" }
    assert_response :redirect
  end

  test "creates a flashcard with the permitted attributes" do
    assert_difference("Flashcard.count", 1) do
      post deck_flashcards_path(@deck), params: { flashcard: { front: "Question", back: "Answer" } }
    end

    assert_redirected_to new_deck_flashcard_path(@deck)
  end

  test "does not create a flashcard without front" do
    assert_no_difference("Flashcard.count") do
      post deck_flashcards_path(@deck), params: { flashcard: { front: "", back: "Answer" } }
    end

    assert_response :unprocessable_entity
  end

  test "updates a flashcard" do
    flashcard = @deck.flashcards.create!(front: "Old", back: "Value")

    patch deck_flashcard_path(@deck, flashcard), params: { flashcard: { front: "New", back: "Content" } }

    assert_redirected_to deck_path(@deck)
    assert_equal [ "New", "Content" ], flashcard.reload.attributes.values_at("front", "back")
  end

  test "blocks direct access to a flashcard without an active review queue" do
    flashcard = @deck.flashcards.create!(front: "Locked", back: "Card")

    get deck_flashcard_path(@deck, flashcard)

    assert_redirected_to deck_path(@deck)
    assert_equal I18n.t("messages.manual_review_access_not_allowed"), flash[:alert]
  end

  test "deletes a flashcard" do
    flashcard = @deck.flashcards.create!(front: "Delete", back: "Me")

    assert_difference("Flashcard.count", -1) do
      delete deck_flashcard_path(@deck, flashcard)
    end

    assert_redirected_to deck_path(@deck)
  end

  test "starts a review session using only due flashcards" do
    due_flashcard = @deck.flashcards.create!(front: "Due", back: "Card")
    future_flashcard = @deck.flashcards.create!(front: "Future", back: "Card")

    due_flashcard.update_column(:fsrs_state, due_flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))
    future_flashcard.update_column(:fsrs_state, future_flashcard.fsrs_state.merge("due" => 2.days.from_now.utc.iso8601))

    assert_difference("ReviewSession.count", 1) do
      get review_deck_path(@deck)
    end

    assert_redirected_to deck_flashcard_path(@deck, due_flashcard)
    assert_equal 1, ReviewSession.order(:id).last.total_count
  end

  test "does not create a second review session when one is already active" do
    first_flashcard = @deck.flashcards.create!(front: "First", back: "Card")
    second_flashcard = @deck.flashcards.create!(front: "Second", back: "Card")

    first_flashcard.update_column(:fsrs_state, first_flashcard.fsrs_state.merge("due" => 2.hours.ago.utc.iso8601))
    second_flashcard.update_column(:fsrs_state, second_flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))

    assert_difference("ReviewSession.count", 1) do
      get review_deck_path(@deck)
    end

    assert_no_difference("ReviewSession.count") do
      get review_deck_path(@deck)
    end

    assert_redirected_to deck_flashcard_path(@deck, first_flashcard)
    assert_equal I18n.t("messages.review_session_already_in_progress"), flash[:alert]
  end

  test "blocks access to a flashcard that is not the current item in the review queue" do
    first_flashcard = @deck.flashcards.create!(front: "First", back: "Card")
    second_flashcard = @deck.flashcards.create!(front: "Second", back: "Card")

    first_flashcard.update_column(:fsrs_state, first_flashcard.fsrs_state.merge("due" => 2.hours.ago.utc.iso8601))
    second_flashcard.update_column(:fsrs_state, second_flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))

    get review_deck_path(@deck)

    get deck_flashcard_path(@deck, second_flashcard)

    assert_redirected_to deck_flashcard_path(@deck, first_flashcard)
    assert_equal I18n.t("messages.manual_review_access_not_allowed"), flash[:alert]
  end

  test "redirects back to the deck when there are no due flashcards" do
    flashcard = @deck.flashcards.create!(front: "Future", back: "Card")
    flashcard.update_column(:fsrs_state, flashcard.fsrs_state.merge("due" => 2.days.from_now.utc.iso8601))

    assert_no_difference("ReviewSession.count") do
      get review_deck_path(@deck)
    end

    assert_redirected_to deck_path(@deck)
  end

  test "rating again keeps the flashcard in queue without inflating reviewed_count" do
    flashcard = @deck.flashcards.create!(front: "Again", back: "Card")
    flashcard.update_column(:fsrs_state, flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))

    get review_deck_path(@deck)
    review_session = ReviewSession.order(:id).last

    post review_deck_flashcard_path(@deck, flashcard), params: { rating: Fsrs::Rating::AGAIN }

    assert_redirected_to deck_flashcard_path(@deck, flashcard)
    assert_equal 0, review_session.reload.reviewed_count
    refute review_session.completed_at?
  end

  test "blocks manual review posts for flashcards outside the active queue position" do
    first_flashcard = @deck.flashcards.create!(front: "First", back: "Card")
    second_flashcard = @deck.flashcards.create!(front: "Second", back: "Card")

    first_flashcard.update_column(:fsrs_state, first_flashcard.fsrs_state.merge("due" => 2.hours.ago.utc.iso8601))
    second_flashcard.update_column(:fsrs_state, second_flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))

    get review_deck_path(@deck)

    post review_deck_flashcard_path(@deck, second_flashcard), params: { rating: Fsrs::Rating::GOOD }

    assert_redirected_to deck_flashcard_path(@deck, first_flashcard)
    assert_equal I18n.t("messages.manual_review_access_not_allowed"), flash[:alert]
  end

  test "completes the session after a successful final review" do
    flashcard = @deck.flashcards.create!(front: "Good", back: "Card")
    flashcard.update_column(:fsrs_state, flashcard.fsrs_state.merge("due" => 1.hour.ago.utc.iso8601))

    get review_deck_path(@deck)
    review_session = ReviewSession.order(:id).last

    post review_deck_flashcard_path(@deck, flashcard), params: { rating: Fsrs::Rating::GOOD }

    assert_redirected_to reviewed_completed_deck_path(@deck)

    review_session.reload
    assert_equal 1, review_session.reviewed_count
    assert review_session.completed_at?
    assert review_session.duration_seconds.present?
  end
end
