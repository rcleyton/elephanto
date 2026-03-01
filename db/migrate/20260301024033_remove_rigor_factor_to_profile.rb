class RemoveRigorFactorToProfile < ActiveRecord::Migration[8.0]
  def change
    remove_column :profiles, :rigor_factor, :decimal
  end
end
