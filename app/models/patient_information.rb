class PatientInformation < ApplicationRecord
  belongs_to :patient

  def adherence
    days = medication_adherence_denominator

    if (!self.patient.has_reported_today && medication_adherence_denominator > 1 && !patient_completed_treatment)
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
      had_severe_symptom_in_past_week: self.patient.had_severe_symptom_in_past_week?,
      had_symptom_in_past_week: self.patient.had_symptom_in_past_week?,
      negative_photo_in_past_week: self.patient.negative_photo_in_past_week?,
      number_of_conclusive_photos: self.patient.number_of_conclusive_photos,
      days_reported_not_taking_medication: self.patient.number_days_reported_not_taking_medication,
    )
  end

  def update_patient_stats
    update_adherence_denominators
    update_adherence_numerators
    update_streak
  end

  def days_since_app_start
    (LocalizedDate.now_in_ar.to_date - self.datetime_patient_activated.to_date).to_i + 1
  end

  def photo_reporting_summary
    {
      requested: self.number_of_photo_requests,
      submitted: self.adherent_photo_days,
      conclusive: self.number_of_conclusive_photos,
      inconclusive: self.adherent_photo_days - self.number_of_conclusive_photos,
    }
  end

  def update_streak
    self.update!(medication_streak: DailyReport.user_streak_days(self.patient))
  end

  def medication_adherence_denominator
    end_date = patient_completed_treatment ? self.patient.treatment_end_date : LocalizedDate.now_in_ar.to_date
    (end_date - self.datetime_patient_activated.to_date).to_i + 1
  end

  def priority
    PriorityCalculator.calculate(adherence, self.had_symptom_in_past_week, self.had_severe_symptom_in_past_week, self.negative_photo_in_past_week)
  end

  private

  def patient_completed_treatment
    self.patient.treatment_end_date < LocalizedDate.now_in_ar.to_date
  end
end
