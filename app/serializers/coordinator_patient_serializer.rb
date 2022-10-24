class CoordinatorPatientSerializer < BasePatientSerializer
  attributes :given_name,
             :family_name,
             :organization_id
             :id,
             :full_name,
             :days_in_treatment,
             :phone_number,
             :status,
             :channel_id,
             :referred_for_exit_interview

  def organization_name
    object.organization.title
  end
end