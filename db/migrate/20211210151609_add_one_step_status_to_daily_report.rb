class AddOneStepStatusToDailyReport < ActiveRecord::Migration[6.0]
  def change
    add_column :daily_reports, :was_one_step, :boolean, null: true
  end
end
