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

  def process_review(flashcard, difficulty, review_queue, session)
    raise ArgumentError, "Dificuldade inválida" unless Flashcard.difficulties.key?(difficulty) 

    flashcard.update!(difficulty: difficulty)
    flashcard.review!(@user)

    review_queue.delete(flashcard.id)
    review_queue << flashcard.id if difficulty == "again"
    
    review_session_id = session[:review_session_id]

    if review_session_id
      review_session = ReviewSession.find_by(id: review_session_id)
      increment(review_session) if review_session
    end

    if review_queue.empty?
      complete_session(review_session)
    end

    review_queue
  end

  private

  def complete_session(review_session)
    @deck.update!(last_reviewed_at: Time.current)
    review_session&.update!(completed_at: Time.current)
  end
  
  def increment(session)
    session.increment!(:reviewed_count)
  end
end

