class Organization::PatientsController < UserController
  before_action :verify_practitioner

  def index
    hash = {}
    pp = Organization.find(params[:organization_id]).patient_priorities
    render(json: Patient.where(organization_id: params[:organization_id]).includes("daily_reports", "medication_reports", "photo_reports").limit(5),each_serializer: PatientShortSerializer, status: :ok)
  end

  private
end
