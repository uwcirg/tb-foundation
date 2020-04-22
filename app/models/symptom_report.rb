class SymptomReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :user
  #has_one :daily_report

   def as_json(*args)
     hash = {
       symptomList: reported_symptoms,
       nausea_rating: nausea_rating
     }

     

     hash["otherSymptoms"] = other if other.nil? || other.empty?
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
