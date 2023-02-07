class PatientInformation < ApplicationRecord

  belongs_to :patient
  has_many :daily_reports, :through => :patient
  after_commit :update_patient_stats, if: :should_update_stats_after_commit

  #WHO Treatment Outcomes: success, default, transferred out, deceased, lost to follow-up. Added  withdraw as a study specific outcome
  enum treatment_outcome: { "success": 0, "default": 1, "transferred": 2, "deceased": 3,  "lost-to-follow-up": 4, "withdraw": 5, "refuse-to-use-app": 6 }

  scope :patient_status, ->(status) {  where( patient: Patient.non_test, patient: {status: status}) }
  

  def activated_date
    return self.datetime_patient_activated
  end

  def adherence
    days = medication_adherence_denominator
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
      adherent_days: number_of_adherent_days,
      had_severe_symptom_in_past_week: self.patient.had_severe_symptom_in_past_week?,
      had_symptom_in_past_week: self.patient.had_symptom_in_past_week?,
      negative_photo_in_past_week: self.patient.negative_photo_in_past_week?,
      number_of_conclusive_photos: self.patient.number_of_conclusive_photos,
      days_reported_not_taking_medication: number_days_reported_not_taking_medication,
    )
  end

  def update_patient_stats
    update_adherence_denominators
    update_adherence_numerators
    update_streak
  end

  def days_since_app_start
    (localized_date - self.datetime_patient_activated.to_date).to_i + 1
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

    return 1 if self.datetime_patient_activated.nil?

    calc_end_date = patient_completed_treatment ? end_date  : localized_date
    days_in_treatment = (calc_end_date - localized_date_activated).to_i + 1

    if (!self.patient.has_reported_today && days_in_treatment > 1 && !patient_completed_treatment)
      days_in_treatment -= 1
    end

    return days_in_treatment
  end

  def priority
    PriorityCalculator.calculate(adherence, self.had_symptom_in_past_week, self.had_severe_symptom_in_past_week, self.negative_photo_in_past_week)
  end

  def localized_date_activated
    self.datetime_patient_activated.in_time_zone("America/Argentina/Buenos_Aires").to_date
  end

  #Redundant with above method, used for dashboard calculation of total 
  def days_requested_since(calculation_start_date=nil)

    if(self.datetime_patient_activated.nil?)
      return 0
    end
  
    begining_date = (!calculation_start_date.nil? && (calculation_start_date > self.datetime_patient_activated)) ? calculation_start_date : self.datetime_patient_activated
    calculation_end_date = patient_completed_treatment ? end_date  : localized_date
    days_in_treatment = (calculation_end_date - begining_date.to_date).to_i + 1

    if (!self.patient.has_reported_today && days_in_treatment > 1 && !patient_completed_treatment)
      days_in_treatment -= 1
    end
    return days_in_treatment
  end

  # add percentage changes to the patient information 
  # or add up/down arrows to the dashboard and trends

  def requested_from_to(from, to)
    # may not be able to re-assign params
    if(self.created_at >= from && self.created_at < to)
        from = self.created_at
    end
    calculation_end_date = patient_completed_treatment ? end_date  : to
    days_in_treatment = (calculation_end_date - from).to_i 

    # add another check to see if date range is today
    if (!self.patient.has_reported_today && days_in_treatment > 1 && !patient_completed_treatment)
      days_in_treatment -= 1
    end

    return days_in_treatment
  end

  private

  def end_date
    self.app_end_date || default_end_date
  end

  def number_of_adherent_days
    return 0 unless !self.datetime_patient_activated.nil?
    self.daily_reports.was_taken.where("daily_reports.date >= ? and daily_reports.date <= ?", localized_date_activated, end_date).group(:date).maximum(:updated_at).count
  end

  def number_days_reported_not_taking_medication
    return 0 unless !self.datetime_patient_activated.nil?
    self.daily_reports.medication_was_not_taken.where("daily_reports.date >= ? and daily_reports.date <= ?", localized_date_activated, end_date).count
  end

  def patient_completed_treatment
    self.patient.status == "Archived"
  end

  def default_end_date
    self.patient.treatment_start.to_date + 6.months
  end

  def should_update_stats_after_commit
    app_end_date_changed? || datetime_patient_activated_changed?
  end

  def localized_date
    self.patient.localized_date
  end


end
