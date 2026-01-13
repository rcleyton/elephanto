class AddDailyLimitsToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :daily_new_limit, :integer
    add_column :profiles, :daily_review_limit, :integer
  end
end
