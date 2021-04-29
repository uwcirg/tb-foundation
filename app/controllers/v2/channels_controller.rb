class V2::ChannelsController < UserController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_action :snake_case_params

  def index
    @channels = policy_scope(Channel)
    render(json: @channels, requesting_user_type: @current_user.type, status: :ok)
  end

  def show
    @channel = policy_scope(Channel).find(params[:id])
    render(json: @channel, requesting_user_type: @current_user.type, status: :ok)
  end

  private

  def user_not_authorized
    render(json: { error: "You do not have access to that channel", code: 401 }, status: 401)
  end
  
end
