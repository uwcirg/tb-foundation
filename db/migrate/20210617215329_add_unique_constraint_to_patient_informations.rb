class AddUniqueConstraintToPatientInformations < ActiveRecord::Migration[6.0]
  def change
    remove_index :patient_informations, :patient_id
    add_index :patient_informations, :patient_id, unique: true
  end
end
