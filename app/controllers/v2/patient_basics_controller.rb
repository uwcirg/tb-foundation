class V2::PatientBasicController < PatientDataController

  before_action :snake_case_params

  def index
    @patients = policy_scope(Patient).includes("patient_information")

    render(json: patients, status: :ok, each_serializer: serializer)
  end

  def show
    patient = Patient.includes(:patient_information).find(params[:id])
    authorize patient
    render(json: patient, serializer: serializer, status: :ok)
  end

  private 

  def serializer
      return PractitionerPatientBasicSerializer if current_user.practitioner?
end