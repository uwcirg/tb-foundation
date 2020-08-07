class Patient::RemindersController < UserController

    before_action :verify_user_access

    def index
        render(json: @selected_patient.reminders, status: :ok)
    end 

    private

    def verify_user_access

        @selected_patient = Patient.find(params["patient_id"])

        if(@selected_patient.nil?)
            render(json: "That patient does not exist", status: 404)
            return
        elsif((@current_user.is_a? Patient) && @selected_patient != @current_user)
            render(json: "You cannot access another patients records", status: 401)
            return
        elsif((@current_user.is_a? Practitioner) && @selected_patient.organization_id != @current_user.organization_id)
            render(json: "You do not have access to that patients records, they belong to another organization", status: 401)
            return
        end
    end

end