require 'webpush'

class LoginController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create_new_participant

    newAccount = Participant.new(
      name: params["name"],
      phone_number: params["phone_number"],
      treatment_start: params["treatment_start"],
      password_digest:  BCrypt::Password.create(params["password"]),
      uuid: SecureRandom.uuid
    )

    newAccount.save

    render(json: newAccount.to_json, status: 200)

  end

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


  #Given a uuid, send a push to that user
  def send_push_to_user
    user = Participant.find(params[:uuid]);

    #Check to make sure their subscription information is up to date
    if(user.push_url.nil? || user.push_auth.nil? || user.push_p256dh.nil?)
      render(json: { error: 'user has no push data' }, status: :unauthorized)
      return
    end

    message = JSON.generate(
      title: params[:message],
      body: "name: #{user.name} uuid: #{user.uuid}",
      icon: "https://images.idgesg.net/images/article/2019/04/google-shift-100794036-large.jpg",
      url: "https://tb-app.cirg.washington.edu"
    )
    
    Webpush.payload_send(
      message: message,
      endpoint: user.push_url,
      p256dh: user.push_p256dh,
      auth: user.push_auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:sender@example.com',
        public_key: "BMSAvU3i4-87WUvEFijxz-sNq7255ACiF8ubt2196lWu9l0U2eLqXeLt-8ZVUXt4djlQyiiJul23VVt7giO1d_U=",
        private_key: "iE2ZXg3t_IaZrm2noz2Z8uW_N0kgea9oVacU-8uXRGg="
      }
    )

    # Webpush.payload_send(
    #   message: params[:message],
    #   endpoint: params[:subscription][:endpoint],
    #   p256dh: params[:subscription][:keys][:p256dh],
    #   auth: params[:subscription][:keys][:auth],
    #   ttl: 24 * 60 * 60,
    #   vapid: {
    #     subject: 'mailto:sender@example.com',
    #     public_key: ENV['VAPID_PUBLIC_KEY'],
    #     private_key: ENV['VAPID_PRIVATE_KEY']
    #   }
    # )
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
