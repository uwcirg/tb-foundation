class CoordinatorPatientSerializer < ActiveModel::Serializer
  attributes :full_name, :days_in_treatment, :referred_for_exit_interview,  :status, :phone_number, :organization_name, 

  def organization_name
    object.organization.title
  end
end