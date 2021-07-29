class V2::PatientController < PatientDataController
  def index
    @patients = policy_scope(Patient).includes("patient_information")

    if (params[:archived])
      filtered_patients = @patients.archived
    else
      filtered_patients = @patients.active
    end

    if(params[:all])
      filtered_patients = @patients.all
    end

    render(json: filtered_patients, status: :ok, each_serializer: serializer)
  end

  def show
    patient = Patient.find(params[:id])
    authorize patient
    render(json: patient, serializer: serializer, status: :ok)
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
    new_params = params.permit(:phone_number, :given_name, :family_name, :id, :treatment_end_date)
    if (new_params[:phone_number])
      new_params[:phone_number] = new_params[:phone_number].delete("^0-9")
    end
    return new_params
  end

  def param_errors(patient)
    patient.errors.as_json.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
  end

  def serializer
    return PractitionerPatientSerializer if @current_user.practitioner?
    return AdminPatientSerializer if @current_user.admin?
    return PatientSerializer
  end
end
