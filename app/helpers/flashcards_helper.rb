# typed: false
# frozen_string_literal: true

module FlashcardsHelper
  def flashcards_studied(user)
    count = 0
    card  = user.decks
    card.each do |len|
      count += len.flashcards.size
    end
    count
  end
end
