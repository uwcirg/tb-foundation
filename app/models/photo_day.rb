class PhotoDay < ApplicationRecord
    belongs_to :patient
    scope :requested, -> { where('date <= CURRENT_DATE') }
    scope :since_last_missing_photo_resolution, -> { where(patient: Patient.where("Active")).joins('LEFT JOIN (SELECT DISTINCT ON (patient_id) * FROM resolutions WHERE kind = 2 ORDER BY patient_id,resolved_at DESC) as resolutions ON resolutions.patient_id = photo_days.patient_id' )
        .where("photo_days.date > resolutions.resolved_at AND photo_days.date < ?", LocalizedDate.today_in_ar) }
    
        scope :missed_or_negative_in_past_week, -> {
        where("photo_days.date > ? AND photo_days.date < ?", Time.now - 1.week, Time.now)
        .joins("LEFT JOIN daily_reports on photo_days.patient_id = daily_reports.user_id AND photo_days.date = daily_reports.date")
        .joins("LEFT JOIN photo_reports on photo_reports.daily_report_id = daily_reports.id")
        .where("photo_reports.id IS NULL OR photo_reports.approved = false")        
    }
end
  