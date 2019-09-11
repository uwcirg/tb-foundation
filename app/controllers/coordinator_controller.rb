require 'securerandom'
class CoordinatorController < AuthenticatedController
    skip_before_action :verify_authenticity_token
    before_action :auth_coordinator

    def reset_password
        random_string = SecureRandom.hex[0,7];
        Participant.update(params["userID"],{password_digest:  BCrypt::Password.create(random_string)} )
        render(json: {new_password: random_string}, status: 200)
    end

end