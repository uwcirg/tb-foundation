class ParticipantController < ApplicationController
    before_action :set_cors_headers
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


    def set_cors_headers
        response.set_header("Allow", "POST")
        response.set_header("Access-Control-Allow-Origin", "*")
        response.set_header("Access-Control-Allow-Headers", "Content-Type")
    end

end