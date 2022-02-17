class LoginController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create_new_participant
    newAccount = Participant.new(
      name: params["name"],
      phone_number: params["phone_number"],
      treatment_start: params["treatment_start"],
      password_digest: BCrypt::Password.create(params["password"]),
      uuid: SecureRandom.uuid,
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

  def get_photo_heatmap
    grouped_hash = get_group_hash

    hash = {}
    grouped_hash.keys.each do |study_id|
      date_hash = {}
      i = 0
      days = []


      relevant_uuids = grouped_hash[study_id]
      participants = Participant.where(uuid: relevant_uuids)

      StripReport.where(participant: participants).map { |p| date_hash["#{p.timestamp.to_date}"] = true }

      #Get earliest start date for the given group of accoutns
      earliest_start_date = participants.order(:created_at).first.created_at.to_date

      #Loop throuhg treatment days
      (earliest_start_date..earliest_start_date + 180.days).each do |day|
        i += 1
        days.push(date_hash["#{day}"] == true ? "taken" : "notTaken")
      end

      hash[study_id] = days
    end

    render(json: hash, status: :ok)
  end 

  def get_heatmap

    grouped_hash = get_group_hash

    hash = {}
    grouped_hash.keys.each do |study_id|
      date_hash = {}
      i = 0
      days = []


      relevant_uuids = grouped_hash[study_id]
      participants = Participant.where(uuid: relevant_uuids)

      MedicationReport.where(participant: participants, took_medication: true).map { |p| date_hash["#{p.timestamp.to_date}"] = true }

      #Get earliest start date for the given group of accoutns
      earliest_start_date = participants.order(:created_at).first.created_at.to_date

      #Loop throuhg treatment days
      (earliest_start_date..earliest_start_date + 180.days).each do |day|
        i += 1
        days.push(date_hash["#{day}"] == true ? "taken" : "notTaken")
      end

      hash[study_id] = days
    end

    render(json: hash, status: :ok)
  end

  private

  def get_group_hash
    cap_hash_local = {
      "9c6639d0-215a-4017-bbec-48be749c3301": 102,
      "ffa14305-8c0d-4646-b290-a4726e8d436f": 103,
      "d113eb86-4a12-4690-9bdc-913012302e2b": 105,
      "52daf48a-4727-4e36-9937-fe8f06b65e63": 124,
      "f9ce51fa-3f24-4670-a83d-61bdb9ee1fe9": 125,
      "4a96769d-f11c-47f0-b787-3bcab81c23b9": 107,
      "a9b4217e-858d-4216-bfcb-b33bc118d2b4": 109,
      "86d0ad85-fca1-4985-984a-27d60f705c53": 111,
      "e2e6b123-b293-41e4-9a90-4ce7f57e57bc": 113,
      "43500505-5b89-40ff-8ca4-8e854832c565": 115,
      "4e0703ee-fb16-4937-937e-ff47ed70fd04": 118,
      "789434b2-7f3d-453b-9f65-67823a73030b": 119,
      "55f0e383-e5fb-4ba0-8dcc-7a53c78884ef": 120,
      "978d07a8-2fcb-4e30-ba87-b7caebe9e74b": 126,
      "ecdac63c-1a90-4810-a0b4-ff24611bc104": 130,
      "245e79a0-7f87-45ba-a022-a7ac62973ea1": 131,
      "49050a92-bd26-498e-893f-97b8ab393077": 134,
      "a7dfbe1a-1916-4940-b6c1-5b0b558b196a": 135,
      "e0f625ea-ff86-4ed0-89ec-07e9dbe71a05": 137,
      "368c36c5-daac-481a-ac74-430cae3162ef": 141,
      "b7156f36-2aea-4d0e-8557-5763cfc0074c": 109,
      "df31380f-36ca-45b1-91c1-02e82dff196a": 137,
      "842e7de3-24ca-467d-97f7-2cad70a8a214": 137,
      "098b37ff-27fe-46f1-a7ca-f6994cb7b93f": 142,
    }

    grouped_hash = {}

    cap_hash_local.keys.each do |hash_key|
      value = cap_hash_local[hash_key]
      if (grouped_hash.key?(value))
        temp_list = grouped_hash[value]
        temp_list.push(hash_key)
        grouped_hash[value] = temp_list
      else
        grouped_hash[value] = [hash_key]
      end
    end
    grouped_hash
  end

  def authenticate
    if @user && BCrypt::Password.new(@user.password_digest) == params[:password]
      token = JsonWebToken.encode(uuid: @user.id)
      time = Time.now + 7.days.to_i
      render json: { token: token, exp: time.iso8601, uuid: @user.id, user_type: @user_type }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
