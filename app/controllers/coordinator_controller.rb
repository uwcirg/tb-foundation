require 'securerandom'

class CoordinatorController < AuthenticatedController
    skip_before_action :verify_authenticity_token
    before_action :auth_coordinator, except: [:generate_zip]

    def reset_password
        random_string = SecureRandom.hex[0,7];
        Participant.update(params["userID"],{password_digest:  BCrypt::Password.create(random_string)} )
        render(json: {new_password: random_string}, status: 200)
    end

    def generate_zip_url
        baseURL = ENV["URL_API"]
        token = JsonWebToken.encode({temp: "true"},5.minutes.from_now)
        url = "#{baseURL}/strip_zip_file?token=#{token}"
        render json: { url: url}, status: :ok
    end

end
