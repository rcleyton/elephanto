class AddTrackingFieldsToReviewSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :review_sessions, :abandoned_at, :datetime
    add_column :review_sessions, :duration_seconds, :integer
    add_column :review_sessions, :accuracy, :float
  end
end
