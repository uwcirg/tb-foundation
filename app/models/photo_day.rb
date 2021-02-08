class PhotoDay < ApplicationRecord
    belongs_to :patient
    scope :requested, -> { where('date <= CURRENT_DATE') }
    scope :since_last_missing_photo_resolution, -> { where(patient: Patient.where("Active")).joins('LEFT JOIN (SELECT DISTINCT ON (patient_id) * FROM resolutions WHERE kind = 2 ORDER BY patient_id,resolved_at DESC) as resolutions ON resolutions.patient_id = photo_days.patient_id' ).where("photo_days.date > resolutions.resolved_at AND photo_days.date < ?", Date.today) }
end
  