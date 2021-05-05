class ApplicationController < ActionController::Base
  include Pundit
  include ::ActionController::Cookies

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized_access

  helper_method :current_user 

  def snake_case_params
    request.parameters.deep_transform_keys!(&:underscore)
  end

  def confirm_password
    if (params["password"] != params["passwordConfirmation"])
      render(json: { error: "Password and Password Confirmation do not match" }, status: 401)
      return false
    else
      return true
    end
  end

  def get_locales
    locales = User.locales
    render(json: locales, status: 200)
  end

  def handle_unauthorized_access
    render(json: { error: "You do not have access to the requested resource", code: 401 }, status: 401)
  end

  private

  def current_user
   @current_user
  end

end
