class MonthSummary < ActiveModelSerializers::Model
  # (Time.local(2022, 7))..(Time.local(2022, 7 + 1) - 1.day) 
  def initialize(from, to, site)
    @site = site
    @start_date = Time.local(from)
    @end_date = (Time.local(to) + 1.day) - 1.second
    @date_range = (start_date)..(end_date)
  end

  


  def photo_reports
    {
      requested: PhotoDay.requested.from_active_patient.within_date_range(date_range).count,
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
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.from_active_patient.within_date_range(date_range)).count
  end

  private

  
  def number_of_reports_requested(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date
    
    archived_patient = PatientInformation.status("Archived")
    active_patient = PatientInformation.status("Active")

    if (archived_patient.where(app_end_date: date_range).or(archived_patient.where(created_at: date_range)))
      # calculate how many days the patient was active between these date ranges
      archived_patient.pluck(:created_at, :app_end_date).reduce(0) { |sum, pi| sum + pi.requested_from_to(start_date, end_date) }
    end
    
    if (active_patient.where(created_at: date_range))
      # calculate how many days the patient was active between these date ranges
      active_patient.pluck(:created_at, :updated_at).reduce(0) { |sum, pi| sum + pi.requested_from_to(start_date, end_date) }
    end

    return active_patient + archived_patient
  end

  

  def submitted_photos
    PhotoReport.where(daily_report_id: DailyReport.from_active_patient.where(date: date_range))
  end

  def submitted_reports
    DailyReport.from_active_patient.where(date: date_range)
  end
end
