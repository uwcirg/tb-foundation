require 'aws-sdk'

class UserController < ApplicationController
  before_action :decode_token, :except => [:login,:upload_lab_test,:generate_presigned_url,:activate_patient,:check_patient_code,:get_all_tests]

  def auth_user
    #Uses @decoded from User Controller(Super Class)
    id = @decoded[:user_id]
    @current_user = User.find(id)
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: "User Not Found" }, status: :unauthorized
  end

  #Authenticaiton Functions
  def decode_token
    jwt = cookies.signed[:jwt]
    begin
      @decoded = JsonWebToken.decode(jwt)
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
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
    organizations = Organization.all();
    render(json: organizations.to_json, status: 200);
  end

  #Destroy cookie for logout
  def logout
    cookies.delete(:jwt)
    render( json: {message: "Logout Successful"}, status: 200)
  end

  def update_user_subscription
    auth_user
    @current_user.update(push_p256dh: params[:p256dh], push_auth: params[:auth], push_url: params[:endpoint])
    render json: { message: "update successful"}, status: 200
  end

  def push_key
    vapid_key = ENV['VAPID_PUBLIC_KEY']
    render(json: {key: vapid_key}, status: 200)
  end

  private

  def authenticate

    if !@user 
        render json: { error: "That #{params[:userType].downcase} does not exist",status: 422 }, status: 422
        return
    end

    if @user && BCrypt::Password.new(@user.password_digest) == params[:password]
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 7.days.to_i
      cookies.signed[:jwt] = {value:  token, httponly: true}
      render json: {user_id: @user.id, user_type: @user.type }, status: :ok
    else
      render json: { error: "Unauthorized: incorrect password", status: :unauthorized }, status: :unauthorized
    end
  end
end
