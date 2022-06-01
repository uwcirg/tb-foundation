class V2::RemindersController < UserController
    before_action :snake_case_params

    def index
        reminders = policy_scope(Reminder).where(patient_id: params[:patient_id])
        render(json: reminders, status: :ok)
    end

    def create
        patient = Patient.find(params[:patient_id])
        reminder = patient.reminders.create(filter_reminder_params.merge(:creator_id => @current_user.id))
        authorize reminder
        reminder.save!
        render(json: reminder, status: 201)
    end
  
    private

    def filter_reminder_params
        params.permit(:title, :datetime, :patient_id, :category, :other_category, :future, :note)
      end

  end
  