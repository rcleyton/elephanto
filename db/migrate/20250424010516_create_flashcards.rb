class CreateFlashcards < ActiveRecord::Migration[8.0]
  def change
    create_table :flashcards do |t|
      t.text :front
      t.text :back
      t.integer :difficulty
      t.datetime :last_reviewed_at
      t.references :deck, null: false, foreign_key: true

      t.timestamps
    end
  end
end
