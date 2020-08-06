class Patient::NotesController < UserController

    before_action :verify_practitioner

    def index
        render(json: @patient.patient_notes.order("created_at DESC"), status: :ok)
    end 

    def show
        render(json: @patient.patient_notes.find(params[:id]), status: :ok)
    end 

    def create
       note = @current_practitoner.patient_notes.create!(create_note_params);
       render(json: note, status: :ok)
    end

    private

    def create_note_params
        params.permit(:title,:note,:patient_id)
    end

    def verify_practitioner
        auth_practitioner

        @patient = @current_practitoner.patients.find_by(id: params[:patient_id])

        if(@patient.nil?)
            render(json: {error: "You're not authorized to view that patients information" }, status: :unauthorized)
            return
        end
    end

  end
  