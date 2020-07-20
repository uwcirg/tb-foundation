class AddPhotoSchedule < ActiveRecord::Migration[6.0]
  def change
    create_table :photo_days do |t|
      t.date :date, null: false
      t.references :patient, foreign_key: { to_table: :users }
    end
    add_index :photo_days, [:patient_id, :date], unique: true
  end
end
