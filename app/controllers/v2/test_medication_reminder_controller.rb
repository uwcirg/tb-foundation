class V2::TestMedicationReminderController < UserController

    def create
        selected_patient = Patient.find(params[:patient_id])
        authorize selected_patient, :update?
        selected_patient.send_medication_reminder
        render(json: {message: "Notification sent successfully"}, status: :ok)
    end

end