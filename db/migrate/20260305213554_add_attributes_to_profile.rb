class AddAttributesToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :country, :string
    add_column :profiles, :state, :string
    add_column :profiles, :city, :string
  end
end
