class AddOneStepStatusToDailyReport < ActiveRecord::Migration[6.0]
  def change
    add_column :daily_reports, :one_step_completion, :boolean, null: true
  end
end
