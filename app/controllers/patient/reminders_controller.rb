class Patient::RemindersController < UserController
  before_action :snake_case_params
  before_action :check_patient_record_access, only: [:index]
  before_action :check_is_patient, only: [:create,:delete]

  #@selected_patient loaded from before action in user_controller.rb

  def index
    if(params[:future])
        render(json: @selected_patient.reminders.where("datetime > ?",DateTime.now() - 1.hour).order("datetime"), status: :ok)
        return
    end
    render(json: @selected_patient.reminders.order("datetime"), status: :ok)
  end

  def create
    new_reminder = @selected_patient.reminders.create!(filter_reminder_params)
    render(json: new_reminder, status: :ok)
  end

  def destroy
    rel = Patient.find(params[:patient_id]).reminders.find(params[:id]).destroy!
    render(json: {message: "Success"}, status: :ok )
  end

  private

  def filter_reminder_params
    params.permit(:title, :datetime, :patient_id, :category, :other_category, :future, :note)
  end


end
