class V2::VapidPublicKeysController < UserController
  before_action :snake_case_params

  def show
    update_push_traking_information
    vapid_key = ENV["VAPID_PUBLIC_KEY"]
    render(json: { key: vapid_key }, status: 200)
  end

  private

  def update_params
    params.permit(:push_client_permission).merge(:push_subscription_updated_at => Time.now)
  end

  def update_push_traking_information
    @current_user.update!(update_params) unless update_params[:push_client_permission].nil?
  end
end
