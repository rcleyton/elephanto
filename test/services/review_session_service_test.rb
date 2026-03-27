# typed: false
# frozen_string_literal: true

require "test_helper"

class ReviewSessionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @deck = decks(:english)
    @service = ReviewSessionService.new(@user, @deck)
  end

  it "requeues AGAIN cards without incrementing reviewed_count" do
    flashcard = @deck.flashcards.create!(front: "Question", back: "Answer")
    review_session = @deck.review_sessions.create!(user: @user, total_count: 1, started_at: 5.minutes.ago)
    session_store = { review_queue: [ flashcard.id ], review_session_id: review_session.id }

    flashcard.stub(:rate!, true) do
      queue = @service.process_review(flashcard, Fsrs::Rating::AGAIN, session_store)

      assert_equal [ flashcard.id ], queue
      assert_equal [ flashcard.id ], session_store[:review_queue]
      assert_equal review_session.id, session_store[:review_session_id]
      assert_equal 0, review_session.reload.reviewed_count
      refute review_session.completed_at?
    end
  end

  it "completes the session when the queue becomes empty" do
    flashcard = @deck.flashcards.create!(front: "Question", back: "Answer")
    review_session = @deck.review_sessions.create!(user: @user, total_count: 1, started_at: 5.minutes.ago)
    session_store = { review_queue: [ flashcard.id ], review_session_id: review_session.id }

    flashcard.stub(:rate!, true) do
      freeze_time do
        queue = @service.process_review(flashcard, Fsrs::Rating::GOOD, session_store)

        assert_empty queue
        assert_equal [], session_store[:review_queue]
        assert_nil session_store[:review_session_id]
        assert_equal review_session.id, session_store[:last_review_session_id]

        review_session.reload
        assert_equal 1, review_session.reviewed_count
        assert review_session.completed_at?
        assert review_session.duration_seconds.positive?
        assert_in_delta Time.current, @deck.reload.last_reviewed_at, 1.second
      end
    end
  end
end
