class ChangeEducationMessageStatusToDays < ActiveRecord::Migration[6.0]
  def change
    rename_column :education_message_statuses, :treatment_week, :treatment_day
    add_index :education_message_statuses, [:patient_id, :treatment_day], unique: true, name: :patient_treatment_day_index
    remove_index :education_message_statuses, name: "patient_treatment_week_index"
  end
end
