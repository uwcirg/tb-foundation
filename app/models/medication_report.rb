class MedicationReport < ApplicationRecord
  belongs_to :participant
  belongs_to :resolution, optional: true
  scope :non_test, -> {where(participant: Participant.non_test)}
end
