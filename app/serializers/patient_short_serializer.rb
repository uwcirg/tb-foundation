class PatientShortSerializer < ActiveModel::Serializer
    attributes :id, :full_name, :organization_id, :reporting_summary
end