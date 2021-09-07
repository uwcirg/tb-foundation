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

  def get_heatmap 
    hash = {}
    Participant.order(:created_at).each do |patient|
      date_hash = {}
      days = []
      patient.medication_reports.where(took_medication: true).map { |p| date_hash["#{p[1]}"] = p[0] }
      activation_date = patient.created_at
      i = 0

      #Didn't track end dates so this might be weird - could check date of last report instead to be better?
      days_in_treatment = 1000

      (activation_date.to_date..activation_date.to_date + 180.days).each do |day|
        i+=1
        if (i > days_in_treatment )
          days.push("futureDate")
        else
          days.push( date_hash["#{day}"] == true ? "taken" : "notTaken")
        end
      end

      hash["#{patient.id}"] = days
    end
    render(json: hash , status: :ok)
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
