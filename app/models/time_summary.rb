class TimeSummary < ActiveModelSerializers::Model
  def initialize(number_of_days = nil)
    if (number_of_days.nil?)
      number_of_days = (Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date - PatientInformation.order(:datetime_patient_activated).first.datetime_patient_activated.to_date).to_i
    end
    @number_of_days = number_of_days
  end

  def photo_reports
    {
      requested: PhotoDay.requested.where(patient: Patient.non_test.active).where("date > ? AND date < ?", Date.today - @number_of_days.days, Date.today).count,
      submitted: submitted_photos.count,
      skipped: submitted_photos.where(photo_was_skipped: true).count,
    }
  end

  def reports
    {
      requested: n_reports,
      submitted: submitted_reports.count,
      needSupport: submitted_reports.where(doing_okay: false).count
    }
  end

  def number_of_symptoms
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.where(patient: Patient.non_test).where("date > ? AND date < ?", Date.today - @number_of_days.days, Date.today)).count
  end

  private

  def n_reports
    Patient.active.non_test.reduce(0) { |sum, patient| sum + ((patient.days_in_treatment >= @number_of_days) ? @number_of_days : patient.days_in_treatment) }
  end

  def submitted_photos
    PhotoReport.where(daily_report_id: DailyReport.where(patient: Patient.non_test).where("date > ? AND date < ?", Date.today - @number_of_days.days, Date.today))
  end

  def submitted_reports
    DailyReport.where(patient: Patient.non_test).where("date > ? AND date < ?", Date.today - @number_of_days.days, Date.today)
  end
end
