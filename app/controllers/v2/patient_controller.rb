class V2::PatientController < UserController
    before_action :snake_case_params
    #before_action :check_patient_record_access, only: [:update]

    def update
        selected_patient = Patient.find(params[:id])
        authorize selected_patient
        selected_patient.update!(update_patient_params)
        render(json: selected_patient, status: :created)
    end

    private

    def update_patient_params
        params.permit(:phone_number, :given_name, :family_name, :id)
    end


end