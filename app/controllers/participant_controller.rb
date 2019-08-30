require 'securerandom'

class ParticipantController < ApplicationController
    before_action :auth_participant, :except => [:create_new_participant,:reset_password]
    
    #Require coordinator authentication for user password reset
    before_action :auth_coordinator, :only => [:reset_password]
    skip_before_action :verify_authenticity_token


    def get_current_participant
        current = Participant.find(@current_user.id);
        render( json: current.to_json, status: 200)
    end

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

    def update_information
        account = Participant.update(@current_user.id,update_params)
        render(json: account.to_json, status: 200)
    end

    def update_password
        if params["password"] == params["password_check"]
            Participant.update(@current_user.id, {password_digest:  BCrypt::Password.create(params["password"])})
            render(json: {message: "Password update sucessful"}, status: 200)
        else 
            render(json: {error: "New password and password_check do not match"},status: 400)
        end

    end

    def reset_password
        random_string = SecureRandom.hex[0,7];
        Participant.update(params["userID"],{password_digest:  BCrypt::Password.create(random_string)} )
        render(json: {new_password: random_string}, status: 200)
    end


    private

    #Protect against updating with blank information
    def  update_params
      params.
        permit(:name, :phone_number,:treatment_start).
        delete_if {|key, value| value.blank? }
    end


end