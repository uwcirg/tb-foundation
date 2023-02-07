class MonthSummary < ActiveModelSerializers::Model
  def initialize(from, to)
    @start_date = Time.parse(from).beginning_of_day
    @end_date = Time.parse(to).end_of_day
    @date_range = (@start_date)..(@end_date)
  end

  def photo_reports
    {
      requested: PhotoDay.requested.from_active_patient.within_date_range(@date_range).count,
      submitted: submitted_photos.count,
      skipped: submitted_photos.where(photo_was_skipped: true).count,
    }
  end

  def reports
    {
      requested: number_of_reports_requested,
      submitted: submitted_reports.count,
      needSupport: submitted_reports.where(doing_okay: false).count
    }
  end

  def number_of_symptoms
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.from_active_patient.within_date_range(@date_range)).count
  end

  private

  
  def number_of_reports_requested
    # patient_scope??

    patients = Patient.includes(:patient_information)
    return patients.reduce(0) { |sum, patient| sum + patient.requested_between(@start_date, @end_date) }
  end

  def submitted_photos
    PhotoReport.where(daily_report_id: DailyReport.from_active_patient.where(date: @date_range))
  end

  def submitted_reports
    DailyReport.from_active_patient.where(date: @date_range)
  end
end
