class ApplicationController < ActionController::Base
  include ::ActionController::Cookies
  protect_from_forgery with: :exception 
  skip_before_action :verify_authenticity_token
  

  def confirm_password

    if(params["password"] != params["passwordConfirmation"])
      render(json: {error: "Password and Password Confirmation do not match"}, status: 401)
      return false
    else
      return true
    end
  end

end
