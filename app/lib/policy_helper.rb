module PolicyHelper
  def patient_belongs_to_practitioner
    @user.type == "Practitioner" && @user.organization_id == @patient.organization_id
  end

  def user_is_current_patient
    @user.id == @patient.id
  end
end
