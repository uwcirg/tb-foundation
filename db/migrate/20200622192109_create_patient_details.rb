class CreatePatientDetails < ActiveRecord::Migration[6.0]
  def change
    # create_table :patient_details do |t|
    #   t.datetime :treatment_start
    #   t.integer :gender
    #   t.string :medication_type
    #   t.string :photo_schedule
    #   t.text :profile_note
    #   t.references :users, :patient, foreign_key: { to_table: :users }
    # end
    add_column :users, :gender, :integer
    add_column :users, :medication_type, :string
    add_column :users, :profile_note, :text


  end
end
