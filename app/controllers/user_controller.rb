require "aws-sdk"

class UserController < ApplicationController
  before_action :decode_token, :except => [:login, :generate_presigned_url, :get_all_tests]
  around_action :switch_locale, :except => [:login, :generate_presigned_url, :get_all_tests]

  def switch_locale(&action)
    auth_user
    locale = @current_user.try(:locale) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  #Find user based on :user_id from the JWT, stored in cookie
  def auth_user
    id = @decoded[:user_id]
    @current_user = User.find(id)
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: "User Not Found" }, status: :unauthorized
  end

  def auth_patient
    auth_user

    if (@current_user.type != "Patient")
      render json: { errors: "Must have type Patient to access route" }, status: :unauthorized
    end
  end

  def auth_practitioner
    auth_user

    if (@current_user.type != "Practitioner")
      render json: { errors: "Must have type Practitioner to access route" }, status: :unauthorized
    end

    @current_practitoner = @current_user
  end

  def login
    case params[:userType] # a_variable is the variable we want to compare
    when "Administrator"
      @user = Administrator.find_by(email: params[:identifier])
    when "Practitioner"
      @user = Practitioner.find_by(email: params[:identifier])
    when "Patient"
      @user = Patient.find_by(phone_number: params[:identifier])
    else
      render json: { error: "Invalid User Type. Possible values: Administrator, Practitioner, or Patient", status: 422 }, status: 422
      return
    end

    authenticate()
  end

  def get_all_organizations
    organizations = Organization.all()
    render(json: organizations.to_json, status: 200)
  end

  def logout
    @current_user.unsubscribe_push
    cookies.delete(:jwt)
    render(json: { message: "Logout Successful" }, status: 200)
  end

  def update_user_subscription
    auth_user
    @current_user.update(push_p256dh: params[:p256dh], push_auth: params[:auth], push_url: params[:endpoint])
    render json: { message: "Update successful" }, status: 200
  end

  def push_key
    vapid_key = ENV["VAPID_PUBLIC_KEY"]
    render(json: { key: vapid_key }, status: 200)
  end

  def update_password
    if (@current_user.check_current_password(params[:currentPassword]))
      if (params[:newPassword] == params[:newPasswordConfirmation])
        @current_user.update_password(params[:newPassword])
        render(json: { message: I18n.t("user_settings.update_success") }, status: 200)
      else
        render(json: { error: I18n.t("user_settings.password_mismatch"), fields: ["newPassword","newPasswordConfirmation"] }, status: 404)
        return
      end
    else
      render(json: { error: I18n.t("user_settings.current_password_incorrect"), fields: ["currentPassword"] }, status: 401)
      return
    end
  end

  private

  #Authenticaiton Functions
  def decode_token
    jwt = cookies.signed[:jwt]
    begin
      @decoded = JsonWebToken.decode(jwt)
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def authenticate

    #User does not exits, return error
    if !@user
      render json: { error: "That #{params[:userType].downcase} does not exist", status: 422 }, status: 422
      return
    end

    #Check if the user has the correct password
    if @user && BCrypt::Password.new(@user.password_digest) == params[:password]
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 7.days.to_i
      cookies.signed[:jwt] = { value: token, httponly: true, expires: Time.now + 1.week }
      render json: { user_id: @user.id, user_type: @user.type }, status: :ok
    else
      render json: { error: "Unauthorized: incorrect password", status: :unauthorized }, status: :unauthorized
    end
  end
end
