class SymptomReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key=> :user_id
  after_commit :update_patient_stats

  
  scope :has_symptom, -> { where("redness=true OR hives=TRUE OR fever=TRUE OR appetite_loss=TRUE OR blurred_vision=TRUE OR sore_belly=TRUE OR yellow_coloration=TRUE OR difficulty_breathing=TRUE OR facial_swelling=TRUE OR nausea=TRUE") }
  scope :high_alert, -> { where("hives=TRUE OR blurred_vision=TRUE OR yellow_coloration=TRUE OR difficulty_breathing=TRUE OR facial_swelling=TRUE OR ( nausea=TRUE AND nausea_rating > 6)") }
  scope :low_alert, -> { has_symptom.where.not(id: high_alert) }

   def as_json(*args)
     hash = {
       symptomList: reported_symptoms,
       nausea_rating: nausea_rating
     }

     hash["otherSymptoms"] = other if other.nil? || other.empty?
     return hash
   end

  def reported_symptoms
    list = %w[
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

    if(!(self.other.nil? || self.other.empty?))
      list.push("other: #{self.other}")
    end
    return list
  end

  def number_symptoms
    reported_symptoms.length
  end

  private

  def update_patient_stats
    self.patient.update_stats_in_background
  end
  
end
