class AddSpaceRepetitionFieldsToFlashcards < ActiveRecord::Migration[8.0]
  def change
    add_column :flashcards, :efactor, :float
    add_column :flashcards, :interval, :integer
    add_column :flashcards, :repetition, :integer
    add_column :flashcards, :next_review, :date
  end
end
