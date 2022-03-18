class AddRedoToPhotoReports < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reports, :redo_flag, :boolean, default: false, null: false
    add_column :photo_reports, :redo_reason, :text, null: true
    add_reference :photo_reports, :redo_for_report, foreign_key: { to_table: :photo_reports }
  end
end
