class AddTimestampsToReportComponents < ActiveRecord::Migration[6.0]
  def change
    remove_column :photo_reports, :captured_at, :datetime
    add_timestamps :photo_reports, null: true 
    add_column :photo_reports, :back_submission, :boolean, :default => false
  end
end
