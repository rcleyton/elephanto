class AddLearningSpeedToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :learning_speed, :decimal, precision: 3, scale: 2, default: 1.0, null: false
  end
end
