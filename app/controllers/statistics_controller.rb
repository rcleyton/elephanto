# typed: false
# frozen_string_literal: true

class StatisticsController < ApplicationController
  def stats
    @total_decks               = current_user.decks.size
    @review_sessions           = ReviewSession.total_review_sessions(current_user.id)
    @total_review_sessions     = @review_sessions.size
    @total_study_time          = @review_sessions.sum(:duration_seconds)
    @total_due_count           = current_user.flashcards.due.count
    @due_flashcards_by_deck    = current_user.flashcards.due.joins(:deck).group("decks.name").count
  end
end
