class AddTermOfUserToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :terms_of_service, :boolean, default: false, null: false
  end
end
