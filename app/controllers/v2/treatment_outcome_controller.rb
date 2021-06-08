class V2::TreatmentOutcomeController < PatientDataController

    def create
        @patient = Patient.find(params[:patient_id])
        authorize @patient, :update_treatment_status?
        @patient.patient_information.update!(patient_information_params)
        @patient.update!(status: "Archived")
        render(json: @patient, status: :ok)
    end

    private

    def patient_information_params
        params.permit(:app_end_date,:treatment_outcome)
    end

end