class AddEducationMessageViews < ActiveRecord::Migration[6.0]
  def change
    create_table :education_message_statuses do |t|
      t.integer :treatment_week, null: false
      t.boolean :was_helpful
      t.references :patient, foreign_key: { to_table: :users }
    end
    add_index :education_message_statuses, [:patient_id, :treatment_week], unique: true, name: :patient_treatment_week_index
  end
end
