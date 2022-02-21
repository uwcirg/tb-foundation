class SymptomReport < ApplicationRecord
  belongs_to :participant
  belongs_to :resolution, optional: true

  scope :non_test, -> {where(participant: Participant.non_test)}

  scope :has_symptoms, -> { where("nausea=true OR redness=true OR hives=true OR fever=true 
    OR appetite_loss=true OR blurred_vision=true OR sore_belly=true 
    OR yellow_coloration=true OR difficulty_breathing=true OR facial_swelling=true 
    OR other != ''") }

  def as_json(*args)
    {
      id: id,
      created_at: created_at,
      reported_symptoms: reported_symptoms,
      nausea_rating: nausea_rating,
      timestamp: timestamp,
      other: other,
      resolution_uuid: resolution_uuid,
    }
  end

  def symptom_count
  end

  def reported_symptoms
    %w[
      redness
      hives
      fever
      appetite_loss
      blurred_vision
      sore_belly
      yellow_coloration
      difficulty_breathing
      facial_swelling
      nausea
    ].select { |symptom| self.send(symptom) }
  end


end