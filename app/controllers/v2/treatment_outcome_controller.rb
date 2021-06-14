class V2::TreatmentOutcomeController < PatientDataController

    def create
        get_patient_information
        @patient.patient_information.update!(patient_information_params)
        @patient.update!(status: "Archived")
        render(json: @patient, status: :ok)
    end

    def update
        get_patient_information
        @patient.patient_information.update!(patient_information_params)
        render(json: @patient, status: 201)
    end

    private

    def get_patient_information
        @patient = Patient.find(params[:patient_id])
        authorize @patient, :update_treatment_status?
    end

    def patient_information_params
        params.permit(:app_end_date,:treatment_outcome)
    end

end