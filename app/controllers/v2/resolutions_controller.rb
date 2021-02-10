class V2::ResolutionsController < UserController
  before_action :snake_case_params
  before_action :auth_practitioner

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end

  def create

    if (!check_patient_id)
      render(json: { error: "Patient ##{params[:patient_id]} does not exist or does not belong to your organization" }, status: :unauthorized)
      return
    end

    puts(resolution_params)
    new_resolution = @current_practitoner.patients.find(params[:patient_id]).resolutions.create!(resolution_params.merge(:practitioner_id => @current_practitoner.id))
    render(json: new_resolution, status: :ok)
  end

  private

  def check_patient_id
    return @current_practitoner.patients.where(id: params[:patient_id]).exists?
  end

  def resolution_params
    params.require([:patient_id, :resolved_at, :kind])
    params.permit(:patient_id, :resolved_at, :kind)
  end

end
