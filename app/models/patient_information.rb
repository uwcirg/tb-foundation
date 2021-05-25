class PatientInformation < ApplicationRecord
    belongs_to :patient

    # t.datetime "datetime_patient_added"
    # t.datetime "datetime_patient_activated"
    # t.integer "reminders_since_last_report", default: 0
    # t.bigint "patient_id", null: false
    # t.datetime "created_at", precision: 6, null: false
    # t.datetime "updated_at", precision: 6, null: false
    # t.integer "adherent_days", default: 0
    # t.integer "adherent_photo_days", default: 0
    # t.integer "number_of_photo_requests", default: 1
    # t.datetime "requests_updated_at", default: "2021-05-25 15:41:34"
    # t.integer "symptoms_in_past_week", default: 0
    # t.integer "severe_symptoms_in_past_week", default: 0
    # t.index ["patient_id"], name: "index_patient_informations_on_patient_id"

    def update_adherence_denominators
        self.update!(number_of_photo_requests: self.patient.number_of_photo_requests, requests_updated_at: Time.now)
    end

    def update_adherence_numerators
        week_symptoms = self.patient.daily_reports.last_week.has_symptoms.exists?
        week_severe_symptoms = self.patient.daily_reports.last_week.has_severe_symptoms.exists?
        week_symptoms && week_severe_symptoms
        #self.update!(adherent_photo_days: self.patient.number_of_days_with_photo_report, adherent_days: self.patient.number_of_adherent_days)
    end

    def update_all_adherence_values
        update_adherence_denominators
        update_adherence_numerators
    end
end
