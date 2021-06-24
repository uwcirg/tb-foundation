class MedicationReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key=> :user_id
  after_commit :update_patient_stats

  private

  def update_patient_stats
    self.patient.update_stats_in_background
  end

end
