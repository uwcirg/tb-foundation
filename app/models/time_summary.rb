class TimeSummary < ActiveModelSerializers::Model
  def initialize(number_of_days = nil)
    if (number_of_days.nil?)
      number_of_days = (Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date - PatientInformation.order(:datetime_patient_activated).first.datetime_patient_activated.to_date).to_i
    end
    @number_of_days = number_of_days 
  end

  def photo_reports
    {
      requested: PhotoDay.requested.where(patient: Patient.non_test.active).where(date: Time.now() -30.days..Time.now).count,
      submitted: submitted_photos.count,
      skipped: submitted_photos.where(photo_was_skipped: true).count,
    }
  end

  def reports
    {
      requested: number_of_reports_requested,
      submitted: submitted_reports.count,
      needSupport: submitted_reports.where(doing_okay: false).count,
      symptoms: all_symptoms
    }
  end

  def number_of_symptoms
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.where(patient: Patient.non_test).where(date: Time.now() -30.days..Time.now)).count
  end

  private

  def start_date
    Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date - @number_of_days
  end
  
  def number_of_reports_requested
    PatientInformation.where(patient: Patient.active.non_test).reduce(0) { |sum, pi| sum + pi.days_requested_since(start_date) }
  end

  def submitted_photos
    PhotoReport.where(daily_report_id: DailyReport.where(patient: Patient.non_test.active).where(date: Time.now() -30.days..Time.now))
  end

  def submitted_reports
    DailyReport.where(patient: Patient.non_test.active).where(date: Time.now() -30.days..Time.now)
  end

  def all_symptoms
    symptoms_hash = {};
    SymptomReport.has_symptom.where(daily_report_id: DailyReport.where(patient: Patient.non_test).where(date: Time.now() -30.days..Time.now)).each { |report| report.reported_symptoms.each {|symptom| if symptoms_hash.include?(symptom); symptoms_hash[symptom] += 1; else symptoms_hash[symptom] = 1; end } }
    symptoms_hash;
  end
  
end
