class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :patient_notes do |t|
        t.timestamps
        t.references :patient, foreign_key: { to_table: :users }, null: false
        t.string :title, null: false
        t.text :note, null: false
        t.references :practitioner, foreign_key: {to_table: :users }, null: false
    end
  end
end
