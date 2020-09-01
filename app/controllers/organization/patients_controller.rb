class Organization::PatientsController < UserController
  before_action :verify_practitioner

  def index
    hash = {}
    pp = Organization.find(params[:organization_id]).patient_priorities
    Organization.find(params[:organization_id]).patients.includes("daily_reports", "medication_reports", "photo_reports", "channels", "messages").each do |patient|
      options = { serializer: PatientShortSerializer }
      serialization = ActiveModelSerializers::SerializableResource.new(patient, options).as_json
      hash["#{patient.id}"] = serialization.merge(pp[patient.id] || {})
    end
    render(json: hash, status: :ok)
  end

  private
end
