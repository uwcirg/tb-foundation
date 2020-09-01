class PatientShortSerializer < ActiveModel::Serializer
    attributes :id, :given_name, :family_name, :organization_id, :reporting_summary
end