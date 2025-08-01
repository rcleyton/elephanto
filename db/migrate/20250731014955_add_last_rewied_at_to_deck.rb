class AddLastRewiedAtToDeck < ActiveRecord::Migration[8.0]
  def change
    add_column :decks, :last_reviewed_at, :datetime
  end
end
