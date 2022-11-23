class PractitionerPatientSerializer < BasePatientSerializer
  attributes :given_name,
             :family_name,
             :id,
             :status,
             :patient_information
end
