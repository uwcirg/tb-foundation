class PatientBasicSerializer < BasePatientSerializer
  attributes :id, :given_name, :family_name, :full_name, :status, :priority


end