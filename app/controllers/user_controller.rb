class UserController < ApplicationController
    before_action :decode_token, :except => [:user_login]
    
    #Authenticaiton Functions
    def decode_token
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = JsonWebToken.decode(header)
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
    end

    def user_login

    end
  
    # def auth_participant
    #   #@decoded = decode_token
    #   @current_user = Participant.find(@decoded[:uuid])
  
    #   rescue ActiveRecord::RecordNotFound => e
    #     render json: { errors: "Unauthorized participant" }, status: :unauthorized
    #   end
    # end
  
    # def auth_coordinator
    #     #@decoded = decode_token
    #   begin
    #     @current_user = Coordinator.find(@decoded[:uuid])
    #   rescue ActiveRecord::RecordNotFound => e
    #     render json: { errors: "Unauthorized participant" }, status: :unauthorized
    #   end
    # end
  
  
    # def auth_any_user
    #   #@decoded = decode_token

    #   begin
    #   @current_user = Participant.find(@decoded[:uuid])
  
    #   rescue ActiveRecord::RecordNotFound => e
  
    #   #This is messy, maybe break into a few methods
    #   begin 
    #       @current_user = Coordinator.find(@decoded[:uuid])
    #   rescue ActiveRecord::RecordNotFound => e
    #       render json: { errors: e.message }, status: :unauthorized
    #   end
    # end
  end