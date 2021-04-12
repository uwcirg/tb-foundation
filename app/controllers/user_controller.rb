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

  def verify_practitioner
    auth_practitioner

    if (@current_practitoner.organization_id != params[:organization_id].to_i)
      render(json: { error: "You're not authorized to view that organization" }, status: :unauthorized)
      return
    end
  end

  def auth_admin
    auth_user

    if (@current_user.type != "Administrator")
      render json: { errors: "Must have type Administrator to access route" }, status: :unauthorized
    end

    @current_practitoner = @current_user
  end

  def login
    snake_case_params

    if(!params[:phone_number].nil?)
      #delete(^0-9) allows users to format their phone numbers as they please
      @user = Patient.find_by(phone_number: params[:phone_number].delete('^0-9') )
    else
      #Must exclude patients from this search - or any patient with nil email will be selected
      @user = User.where.not(type: "Patient").find_by(email: params[:email])
    end

    authenticate()
  end

  def get_current_user
    render(json: @current_user, status: :ok)
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
        render(json: { error: I18n.t("user_settings.password_mismatch"), fields: ["newPassword", "newPasswordConfirmation"] }, status: 404)
        return
      end
    else
      render(json: { error: I18n.t("user_settings.current_password_incorrect"), fields: ["currentPassword"] }, status: 401)
      return
    end
  end

  # ----- Patient record access control methods

  #Authorize a patient or a practitioner to view records
  def check_patient_record_access
    patient_id = params["patient_id"] || params["id"]
    @selected_patient = Patient.find(patient_id) rescue nil

    if (@selected_patient.nil?)
      render(json: "That patient does not exist", status: 404)
    elsif ((@current_user.is_a? Patient) && @selected_patient != @current_user)
      render(json: "You cannot access another patients records", status: 401)
      return
    elsif ((@current_user.is_a? Practitioner) && @selected_patient.organization_id != @current_user.organization_id)
      render(json: "You do not have access to that patients records, they belong to another organization", status: 401)
      return
    end
  end

  def check_is_patient
    @selected_patient = Patient.find(params["patient_id"]) rescue nil

    if (@current_user != @selected_patient)
      render(json: "You cannot access another patients records", status: 401)
    end
  end

  def snake_case_params
    request.parameters.deep_transform_keys!(&:underscore)
  end

  private

  #Authenticaiton Functions
  def decode_token
    jwt = cookies.signed[:jwt] || bearer_token
    begin
      @decoded = JsonWebToken.decode(jwt)
    rescue JWT::DecodeError => e
      render json: { status: 401, errors: e.message }, status: :unauthorized
    end
  end

  def authenticate

    #User does not exits, return error
    if !@user
      render json: { error: "That user does not exist", status: 422, isLogin: true }, status: 422
      return
    end

    #Check if the user has the correct password
    if @user && BCrypt::Password.new(@user.password_digest) == params[:password]
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 7.days.to_i
      cookies.signed[:jwt] = { value: token, httponly: true, expires: Time.now + 1.week }
      render json: { user_id: @user.id, user_type: @user.type, token: token }, status: :ok
    else
      render json: { error: "Unauthorized: incorrect password", status: 401, isLogin: true }, status: :unauthorized
    end
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

end
