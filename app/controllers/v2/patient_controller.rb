class V2::PatientController < UserController
  before_action :snake_case_params
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, :with => :patient_not_found

  def show
    patient = find_and_authorized_patient
    render(json: patient, status: :ok)
  end

  def update
    patient = find_and_authorized_patient
    patient.update(update_patient_params)

    if patient.save
      render(json: patient, status: :created)
    else
      render(json: { code: 422, paramErrors: param_errors(patient) }, status: 422)
    end
  end

  private

  def find_and_authorized_patient
    selected_patient = Patient.find(params[:id])
    authorize selected_patient
    return selected_patient
  end

  def update_patient_params
    params.permit(:phone_number, :given_name, :family_name, :id)
  end

  def patient_not_found
    render(json: { error: "A patient with id #{params[:id]} does not exist", code: 404 }, status: 404)
  end

  def user_not_authorized
    render(json: { error: "You are not authorized to access that patients records", code: 401 }, status: 401)
  end

  def param_errors(patient)
    patient.errors.as_json.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
  end

end
