class V2::ContactTracingController < PatientDataController

    def index
        authorize Patient.find(params[:patient_id]), :show?
        contact_tracing = ContactTracing.find_by(patient_id: params[:patient_id])

        if(contact_tracing.nil?)
            render(json: { error: "Patient #{params[:patient_id]} does not have contact tracing information", code: 401 }, status: 401)
            return
        end

        render(json: contact_tracing  , status: :ok)
    end

    
end