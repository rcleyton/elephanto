class CreateAddAttributesToDecks < ActiveRecord::Migration[8.0]
  def change
    add_column :decks, :archived, :boolean, default: false
    add_column :decks, :favorite, :boolean, default: false
  end
end
