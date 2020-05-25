class PatientSerializer < ActiveModel::Serializer
    
    attributes :id, :given_name, :family_name, :daily_reports

end