class AddUserIdToDeck < ActiveRecord::Migration[8.0]
  def change
    add_reference :decks, :user, null: false, foreign_key: true
  end
end
