# typed: false
# frozen_string_literal: true

class ReviewSessionService
  def initialize(user, deck)
    @user = user
    @deck = deck
  end

  def start
    flashcards = @deck.flashcards.due.order(:next_review)
    return if flashcards.empty?

    session = ReviewSession.create!(
      user: @user,
      deck: @deck,
      total_count: flashcards.size,
      reviewed_count: 0,
      started_at: Time.current
    )

    session
  end

  def increment(session)
    session.increment!(:reviewed_count)
    if session.complete?
      session.update!(completed_at: Time.current)
      @deck.update!(last_reviewed_at: Time.current)
    end
  end
end

