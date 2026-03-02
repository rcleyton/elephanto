class AddVisualToDecks < ActiveRecord::Migration[8.0]
  def change
    add_column :decks, :tag, :string
    add_column :decks, :cover_color, :string
  end
end
