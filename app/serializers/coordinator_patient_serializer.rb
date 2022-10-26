class CoordinatorPatientSerializer < BasePatientSerializer
  attributes
             :full_name,
             :id,    
             :organization_name,
             :phone_number,
             :referred_for_exit_interview
             :days_in_treatment,
             :status,
             :channel_id,

  def organization_name
    object.organization.title
  end
end