# typed: false
# frozen_string_literal: true

class StatisticsController < ApplicationController
  def stats
    @total_decks           = current_user.decks.size
    @total_review_sessions = ReviewSession.total_review_sessions(current_user.id).size
  end
end
