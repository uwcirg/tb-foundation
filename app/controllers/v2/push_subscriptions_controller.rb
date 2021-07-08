class V2::PushSubscriptionsController < UserController
  before_action :snake_case_params
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized_access

  def update
    @requested_user = User.find(params[:user_id])
    authorize @requested_user, policy_class: UserPolicy
    @requested_user.update!(update_params.merge(:push_subscription_updated_at => Time.now))
    render(json: {status: "ok"}, status: :ok)
  end

  private

  def update_params
    params.permit(:push_auth, :push_url, :push_p256dh, :push_client_permission)
  end

end
