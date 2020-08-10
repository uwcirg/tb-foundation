class CreatePatientReminders < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders do |t|
      t.datetime :datetime, null: false
      t.integer :category, null: false
      t.references :patient, foreign_key: { to_table: :users }
      t.boolean :send_push, default: true
      t.string :other_category
    end
  end
end
