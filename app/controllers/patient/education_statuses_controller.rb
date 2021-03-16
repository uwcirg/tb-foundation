class Patient::EducationStatusesController < UserController
  before_action :snake_case_params #Convert parameters from camelCase to snake_case
  before_action :check_is_patient  #Gives access to @selected_patient from user_controller.rb

  def index
    render(json: @selected_patient.education_message_statuses, status: :ok)
  end

  def create
    status = @selected_patient.education_message_statuses.create(create_status_params)

    if (status.save!)
      render(json: @selected_patient.education_message_statuses, status: :ok)
    else
      render(json: { message: "Problem updating education message status" }, status: 500)
    end

  rescue ActiveRecord::RecordNotUnique
    render(json: { message: "Already marked as read" }, status: 422)
  end

  private

  def create_status_params
    params.permit(:patient_id,:treatment_day,:was_helpful)
  end
end
