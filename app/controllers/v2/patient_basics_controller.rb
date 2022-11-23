class V2::PatientBasicsController < PatientDataController

  before_action :snake_case_params

  def index
    @patients = policy_scope(Patient)
    render(json: patients, status: :ok, each_serializer: serializer)
  end

  private 

  def serializer
      return PractitionerPatientBasicSerializer if current_user.practitioner?
end