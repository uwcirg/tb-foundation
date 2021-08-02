class AddIndexForUniqueDailyReports < ActiveRecord::Migration[6.0]
  def change
    add_index :daily_reports, [:user_id, :date], unique: true
  end
end
