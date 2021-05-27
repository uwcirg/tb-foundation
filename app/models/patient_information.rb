class PatientInformation < ApplicationRecord
  belongs_to :patient
  after_update :reload_test

  #   create_table "patient_informations", force: :cascade do |t|
  #     t.datetime "datetime_patient_added"
  #     t.datetime "datetime_patient_activated"
  #     t.integer "reminders_since_last_report", default: 0
  #     t.bigint "patient_id", null: false
  #     t.datetime "created_at", precision: 6, null: false
  #     t.datetime "updated_at", precision: 6, null: false
  #     t.integer "adherent_days", default: 0
  #     t.integer "adherent_photo_days", default: 0
  #     t.integer "number_of_photo_requests", default: 1
  #     t.datetime "requests_updated_at", default: "2021-05-25 20:15:49"
  #     t.boolean "had_symptoms_in_past_week", default: false
  #     t.boolean "had_severe_symptoms_in_past_week", default: false
  #     t.index ["patient_id"], name: "index_patient_informations_on_patient_id"
  #   end

  def adherence
    days = days_since_app_start 

    if (!self.patient.has_reported_today && days_since_app_start > 1)
      days = days - 1
    end

    return (self.adherent_days.to_f / days.to_f).round(2)
  end

  def photo_adherence
    return (self.adherent_photo_days.to_f / self.number_of_photo_requests.to_f).round(2)
  end

  def update_adherence_denominators
    self.update!(number_of_photo_requests: self.patient.number_of_photo_requests, requests_updated_at: Time.now)
  end

  def update_adherence_numerators
    self.update!(
      adherent_photo_days: self.patient.number_of_days_with_photo_report,
      adherent_days: self.patient.number_of_adherent_days,
      had_severe_symptoms_in_past_week: self.patient.had_severe_symptom_in_past_week?,
      had_symptoms_in_past_week: self.patient.had_symptom_in_past_week?,
      negative_photo_in_past_week: self.patient.negative_photo_in_past_week?
    )
  end

  def update_all_adherence_values
    update_adherence_denominators
    update_adherence_numerators
  end

  def days_since_app_start
    (LocalizedDate.now_in_ar.to_date - self.datetime_patient_activated.to_date).to_i + 1
  end

  private
  
  def reload_test
    self.patient.patient_information.reload
  end

end
