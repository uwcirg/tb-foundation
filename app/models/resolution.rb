class Resolution < ApplicationRecord
  belongs_to :practitioner
  belongs_to :patient

  after_create :resolve_now

  enum kind: { Symptom: 0, MissedMedication: 1, MissedPhoto: 2, NeedSupport: 3, General: 4}

  scope :last_symptom_from_user, -> {where(kind: "Symptom").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_medication_from_user, -> {where(kind: "MissedMedication").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_support_request, -> {where(kind: "NeedSupport").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_photo_request, -> {where(kind: "MissedPhoto").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}
  scope :last_general_from_user, -> {where(kind: "General").select("DISTINCT ON (patient_id) id").order(:patient_id, resolved_at: :desc)}

  def resolve_now
    if (self.resolved_at.nil?)
      self.resolved_at = DateTime.now
    end
  end

end
