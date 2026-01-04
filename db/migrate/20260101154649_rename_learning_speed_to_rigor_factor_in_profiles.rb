class RenameLearningSpeedToRigorFactorInProfiles < ActiveRecord::Migration[8.0]
  def change
    rename_column :profiles, :learning_speed, :rigor_factor

    change_column :profiles, :rigor_factor, :decimal, precision: 5, scale: 2, default: 9.0
  end
end
