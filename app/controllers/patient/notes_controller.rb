class Patient::NotesController < UserController

    before_action :verify_practitioner

    def index
        render(json: @patient.patient_notes, status: :ok)
    end 

    def show
        render(json: @patient.patient_notes.find(params[:id]), status: :ok)
    end 

    private

    def verify_practitioner
        auth_practitioner

        @patient = @current_practitoner.patients.find(params[:patient_id])

        if(@patient.nil?)
            render(json: {error: "You're not authorized to view that patients information" }, status: :unauthorized)
            return
        end
    end

  end
  