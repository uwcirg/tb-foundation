class AdminPatientSerializer < BasePatientSerializer
  attributes :id, :organization_id, :adherence, :photo_adherence, :treatment_start, :days_in_treatment, :back_submission_ratio, :organization_name, :number_of_messages_from_assistant

  def organization_name
    object.organization.title
  end
end
