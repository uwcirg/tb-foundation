class PatientAnonSerializer < ActiveModel::Serializer
    attributes :id, :organization_id, :adherence, :treatment_start

  end
  