class Patient::RemindersController < UserController
  before_action :check_patient_record_access, only: [:index]
  before_action :check_is_patient, only: [:create]

  #@selected_patient loaded from before action in user_controller.rb

  def index
    render(json: @selected_patient.reminders, status: :ok)
  end

  def create
    new_reminder = @selected_patient.reminders.create!(filter_reminder_params)
    render(json: new_reminder, status: :ok)
  end

  private

  def filter_reminder_params
    params.permit(:title, :datetime, :patient_id, :category, :other_category)
  end


end
