class Resolution < ApplicationRecord
  belongs_to :practitioner
  belongs_to :patient
  enum type: { Symptom: 0, MissedMedication: 1, MissedPhoto: 2 }
end
