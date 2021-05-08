class CreatePatientInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :patient_informations do |t|
      t.datetime :datetime_patient_added
      t.datetime :datetime_patient_activated
      t.integer :reminders_since_last_report, default: 0
      t.references :patient, foreign_key: { to_table: :users }, null: false
      t.timestamps
    end
  end
end
