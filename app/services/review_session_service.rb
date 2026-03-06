# typed: false
# frozen_string_literal: true

class ReviewSessionService
  def initialize(user, deck)
    @user = user
    @deck = deck
  end

  def process_review(flashcard, rating, session_store)
    queue = session_store[:review_queue] || []

    flashcard.rate!(rating)

    queue.delete(flashcard.id)

    queue << flashcard.id if rating.to_i == Fsrs::Rating::AGAIN

    if (review_session = ReviewSession.find_by(id: session_store[:review_session_id]))
      review_session.increment!(:reviewed_count)

      if queue.empty?
        complete_session(review_session)

        session_store[:last_review_session_id] = review_session.id
        session_store.delete(:review_session_id)
        session_store.delete(:review_queue)
      end
    end

    session_store[:review_queue] = queue
    queue
  end

  private

  def complete_session(review_session)
    @deck.update!(last_reviewed_at: Time.current)
    review_session.update!(
      completed_at: Time.current,
      duration_seconds: (Time.current - review_session.started_at).to_i
    )
  end
end
