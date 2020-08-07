class CreatePatientReminders < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders do |t|
      t.datetime :date, null: false
      t.integer :type, null: false, default: 0
      t.string :note
      t.references :patient, foreign_key: { to_table: :users }
    end
  end
end
