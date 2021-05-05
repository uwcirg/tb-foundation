class V2::PushNotificationStatusController < UserController
    before_action :snake_case_params
    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized_access

  def update
    status = PushNotificationStatus.find(params[:id])
    authorize status
    status.update!(update_status_params)
    head :created
  end

  private

  def update_status_params
    params.permit(:id, :delivered_successfully, :delivered_at, :clicked, :clicked_at)
  end

end
