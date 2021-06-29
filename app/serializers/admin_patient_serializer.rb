class AdminPatientSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :adherence, :photo_adherence, :treatment_start, :days_in_treatment
end
