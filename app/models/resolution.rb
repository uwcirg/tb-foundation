class Resolution < ApplicationRecord
  belongs_to :practitioner
  belongs_to :patient

  after_create :resolve_now

  enum kind: { Symptom: 0, MissedMedication: 1, MissedPhoto: 2, NeedSupport: 3}
  scope :latest, -> { where(:date => (Time.now.to_date)) }
  scope :last_symptom_from_user, -> {where(kind: "Symptom").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_medication_from_user, -> {where(kind: "MissedMedication").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_support_request, -> {where(kind: "NeedSupport").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}


  #validates :kind, uniqueness: { scope: [:practitioner_id, :patient_id] }

  def resolve_now
    if (self.resolved_at.nil?)
      #For development - @TODO change to DateTime.now
      self.resolved_at = self.patient.treatment_start
    end
  end
end
