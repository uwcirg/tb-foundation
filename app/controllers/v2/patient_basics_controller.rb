class V2::PatientBasicsController < PatientDataController

  def index
    @patients = policy_scope(Patient).includes("patient_information")
    
    all_patients = @patients.all

    render(json: all_patients, status: :ok, each_serializer: serializer)
  end

  def serializer
      return PatientBasicSerializer 
  end
  
end