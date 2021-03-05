class Patient::PasswordResetController < UserController
  before_action :check_patient_record_access #Inherited method from UserController, gives access to @selected_patient

  def create
    code = @selected_patient.reset_password
    render(json: { temporaryPassword: code }, status: :created)
  end
end
