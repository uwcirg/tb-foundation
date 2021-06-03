class AdminPatientSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :adherence, :treatment_start, :days_in_treatment
end
