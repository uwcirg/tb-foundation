class ApplicationController < ActionController::Base
  include ::ActionController::Cookies
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  def confirm_password
    if (params["password"] != params["passwordConfirmation"])
      render(json: { error: "Password and Password Confirmation do not match" }, status: 401)
      return false
    else
      return true
    end
  end

  def check_patient_code
    if (check_patient_activation_code)
      render(json: { validCode: true }, status: 200)
    else
      if (@temp_account)
        render(json: { validCode: false }, status: 401)
      else
        render(json: { validCode: false }, status: 422)
      end
    end
  end

  def check_patient_activation_code
    @temp_account = TempAccount.where(phone_number: params["phoneNumber"]).first()
    return (@temp_account && BCrypt::Password.new(@temp_account.code_digest) == params["activationCode"])
  end
end
