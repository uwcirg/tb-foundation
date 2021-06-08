class AddTreatmentOutcomeToPatientInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :patient_informations, :treatment_outcome, :integer
    add_column :patient_informations, :datetime_patient_archived, :datetime
    add_column :patient_informations, :app_end_date, :date
  end
end
