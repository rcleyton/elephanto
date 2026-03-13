class AddLocationToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :location, :string
    add_column :profiles, :location_country, :string

    remove_column :profiles, :country, :string
    remove_column :profiles, :country_code, :string
    remove_column :profiles, :state, :string
    remove_column :profiles, :state_code, :string
    remove_column :profiles, :city, :string
  end
end
