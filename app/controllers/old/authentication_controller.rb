class AuthenticationController < ApplicationController

  # def create_new_participant

  #   newAccount = Participant.new(
  #     name: params["name"],
  #     phone_number: params["phone_number"],
  #     treatment_start: params["treatment_start"],
  #     password_digest:  BCrypt::Password.create(params["password"]),
  #     uuid: SecureRandom.uuid
  #   )

  #   newAccount.save

  #   render(json: newAccount.to_json, status: 200)

  # end

  # POST /auth/login

  def login_participant
    @user = Participant.find_by(phone_number: params[:phone_number])
    @user_type = "participant"
    authenticate()
  end

  def login_coordinator
    @user = Coordinator.find_by(email: params[:email])
    @user_type = "coordinator"
    authenticate()
  end
  
  def push_key
    vapid_key = ENV['VAPID_PUBLIC_KEY']
    render(json: {key: vapid_key}, status: 200)
  end

  def update_user_subscription
    user = Participant.find(params[:uuid])
    user.update(push_p256dh: params[:p256dh], push_auth: params[:auth], push_url: params[:endpoint])
    render json: { message: "update successful" }, status: 200
  end

  private

  def authenticate

    if @user && BCrypt::Password.new(@user.password_digest) == params[:password]
        token = JsonWebToken.encode(uuid: @user.id)
        time = Time.now + 7.days.to_i
        render json: { token: token, exp: time.iso8601, uuid: @user.id, user_type: @user_type }, status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
  end

end