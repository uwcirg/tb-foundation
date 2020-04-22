class AddUserToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reports, :user_id, :bigint, null: false
    add_column :medication_reports, :user_id, :bigint, null: false
    add_column :symptom_reports, :user_id, :bigint, null: false
  end
end
