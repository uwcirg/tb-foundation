class AddResolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :resolutions do |t|
      t.timestamps
      t.string :note
      t.integer :kind, null: false
      t.bigint :practitioner_id
      t.bigint :patient_id
    end
    add_index :resolutions, [:practitioner_id, :patient_id,:kind], unique: true
  end
end
