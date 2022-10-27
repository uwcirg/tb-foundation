class CoordinatorPatientSerializer < BasePatientSerializer
  attributes
             :full_name,
             :id,    
             :phone_number,
             :organization_name,
             :referred_for_exit_interview
             :days_in_treatment,
             :status,

  def organization_name
    object.organization.title
  end
end