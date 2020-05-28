class Resolution < ApplicationRecord
  belongs_to :practitioner
  belongs_to :patient
  
  enum kind: { Symptom: 0, MissedMedication: 1, MissedPhoto: 2 }

  validates :kind, uniqueness: { scope: [:practitioner_id, :patient_id] }
end
