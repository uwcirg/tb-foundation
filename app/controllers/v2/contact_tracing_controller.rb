class V2::ContactTracingController < UserController
    before_action :snake_case_params

    def index
        authorize Patient.find(params[:patient_id])
        render(json: ContactTracing.find_by(patient_id: params[:patient_id]) , status: :ok)
    end

    
end