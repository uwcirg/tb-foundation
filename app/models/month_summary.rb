class MonthSummary < ActiveModelSerializers::Model
  # (Time.local(2022, 7))..(Time.local(2022, 7 + 1) - 1.day) 
  def initialize(month, year)
    @month = month
    @year = year
    @start_of_month = Time.local(year, month)
    @end_of_month = (Time.local(year, month + 1) - 1.second)
    @date_range = (start_of_month)..(end_of_month)
  end


  def photo_reports
    {
      requested: PhotoDay.requested.where(patient: Patient.non_test.active).where(date: date_range).count,
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
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.where(patient: Patient.non_test).where(date: date_range)).count
  end

  private

  
  def number_of_reports_requested
    # Where is the days_requested_since method coming from?
    # we need to make sure the patient is active
    # status may be active, but are they really?
    # end dates do not line up with active
    PatientInformation.where(patient: Patient.active.non_test).reduce(0) { |sum, pi| sum + pi.requested_from_to(start_of_month, end_of_month) }
  end

  

  def submitted_photos
    PhotoReport.where(daily_report_id: DailyReport.where(patient: Patient.non_test.active).where(date: date_range))
  end

  def submitted_reports
    DailyReport.where(patient: Patient.non_test.active).where(date: date_range)
  end
end
