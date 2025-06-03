class Flashcard < ApplicationRecord
  belongs_to :deck

  enum :difficulty, { easy: 0, medium: 1, hard: 2, again: 3 }

  validates :front,      presence: true
  validates :back,       presence: true
  validates :difficulty, inclusion: { in: difficulties.keys }, allow_nil: true 
end
