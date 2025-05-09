class Flashcard < ApplicationRecord
  belongs_to :deck

  validates :front,      presence: true
  validates :back,       presence: true
  validates :difficulty, presence: true, allow_blank: true

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }
end
