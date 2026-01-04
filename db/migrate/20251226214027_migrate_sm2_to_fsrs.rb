class MigrateSm2ToFsrs < ActiveRecord::Migration[8.0]
  def change
    change_table :flashcards do |t|
      t.float :stability, default: 0.1, null: false
      t.float :difficulty_score, default: 5.0, null: false
      
      t.remove :efactor, type: :float
    end
  end
end
