class AdminPatientSerializer < BasePatientSerializer
  attributes :id, :organization_id, :adherence, :photo_adherence, :treatment_start, :days_in_treatment, :back_submission_ratio
end
