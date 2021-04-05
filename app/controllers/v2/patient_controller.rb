class V2::PatientController < UserController
    before_action :snake_case_params
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def show
        patient = find_and_authorized_patient
        render(json: patient, status: :ok)
    end 

    def update
        patient = find_and_authorized_patient
        patient.update!(update_patient_params)
        render(json: patient, status: :created)
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

    def user_not_authorized
        render(json: {error: "You are not authorized to access that patients records", code: 401
            },status: 401)
    end


end