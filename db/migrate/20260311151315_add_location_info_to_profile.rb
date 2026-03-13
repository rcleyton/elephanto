class AddLocationInfoToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :state_code, :string
    add_column :profiles, :country_code, :string
  end
end
