class AddDatesAndOfflineStateToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :medication_reports, :date, :date
    add_column :symptom_reports, :date, :date
    add_column :photo_reports, :date, :date
    add_column :daily_reports, :created_offline, :boolean, default: false
  end
end
