class CreatePatientInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :patient_informations do |t|
      t.datetime :datetime_created
      t.datetime :datetime_activated
      t.integer :reminders_since_last_report
      t.references :patient, foreign_key: { to_table: :users }, null: false
      t.timestamps
    end
  end
end
