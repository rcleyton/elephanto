class UpdateFlashcardsAttributes < ActiveRecord::Migration[8.0]
  def change
    add_column :flashcards, :fsrs_state, :json

    remove_column :flashcards, :difficulty, :integer
    remove_column :flashcards, :last_reviewed_at, :datetime
    remove_column :flashcards, :interval, :integer
    remove_column :flashcards, :repetition, :integer
    remove_column :flashcards, :next_review, :date
    remove_column :flashcards, :stability, :float
    remove_column :flashcards, :difficulty_score, :float
  end
end
