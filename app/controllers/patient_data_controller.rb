#Includes the common functions used when accessing a patient, or any of thier records.
#Provides error handling for pundit errors

class PatientDataController < UserController
  before_action :snake_case_params
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, :with => :patient_not_found

  def patient_not_found
    render(json: { error: "A patient with id #{params[:patient_id]} does not exist", code: 404 }, status: 404)
  end

  def user_not_authorized
    render(json: { error: "You are not authorized to access that patients records", code: 401 }, status: 401)
  end
end
