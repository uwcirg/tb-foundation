class SymptomReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key => :user_id
  after_commit :update_patient_stats

  scope :has_symptom, -> (locale = self.env_locale ) { where(self.get_locale_symptom_query(locale)) }
  scope :has_severe_symptom, -> (locale = self.env_locale) { where(self.get_locale_severe_symptom_query(locale)) }
  scope :low_alert, -> { has_symptom.where.not(id: has_severe_symptom) }

  def self.locale_symptoms(deploy_id)
    case deploy_id
    when "id"
      ["redness",
       "vertigo",
       "yellow_coloration",
       "confusion",
       "blurred_vision",
       "oliguria",
       "appetite_loss",
       "nausea",
       "joint_pain",
       "burning_or_numbness",
       "flu_symptoms",
       "red_urine",
       "sleepy"]
    else
      ["redness",
       "hives",
       "fever",
       "appetite_loss",
       "blurred_vision",
       "sore_belly",
       "yellow_coloration",
       "difficulty_breathing",
       "facial_swelling",
       "nausea"]
    end
  end

  def self.locale_severe_symptoms(deploy_id)
    case deploy_id
    when "id"
      ["redness",
       "vertigo",
       "yellow_coloration",
       "confusion",
       "blurred_vision",
       "oliguria"]
    else
      ["hives",
       "blurred_vision",
       "yellow_coloration",
       "difficulty_breathing",
       "facial_swelling"]
    end
  end

  def as_json(*args)
    hash = {
      symptomList: reported_symptoms,
      nausea_rating: nausea_rating,
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
      vertigo
      confusion
      oliguria
      joint_pain
      burning_or_numbness
      flu_symptoms
      red_urine
      sleepy
    ].select { |symptom| self.send(symptom) }

    if (!(self.other.nil? || self.other.empty?))
      list.push("other: #{self.other}")
    end
    return list
  end

  def number_symptoms
    reported_symptoms.length
  end

  private

  def self.get_locale_symptom_query(locale)
    self.build_query(self.locale_symptoms(locale))
  end

  def self.get_locale_severe_symptom_query(locale)
    self.build_query(self.locale_severe_symptoms(locale))
  end

  def self.build_query(symptom_list)
    query = ""
    symptom_list.each_with_index do |symptom_name, index|
      query += " OR " if index != 0
      query += "#{symptom_name}=TRUE"
    end
    query
  end

  def update_patient_stats
    self.patient.update_stats_in_background
  end

  def self.env_locale
    ENV["INDONESIA_PILOT_FLAG"] == 'true' ? "id" : "es-Ar"
  end

end
