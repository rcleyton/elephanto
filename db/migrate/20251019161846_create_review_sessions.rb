class CreateReviewSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :review_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :deck, null: false, foreign_key: true
      t.integer :total_count, default: 0, null: false
      t.integer :reviewed_count, default: 0, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
