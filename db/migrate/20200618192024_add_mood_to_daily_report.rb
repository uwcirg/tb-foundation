class AddMoodToDailyReport < ActiveRecord::Migration[6.0]
  def change
      add_column :daily_reports, :doing_okay, :boolean
  end
end
