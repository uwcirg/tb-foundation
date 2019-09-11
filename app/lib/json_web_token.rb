class JsonWebToken
    SECRET_KEY = Rails.application.secrets.secret_key_base. to_s
  
    #Originally set to 24hour expiry, changed to 5day for production
    # def self.encode(payload, exp = 24.hours.from_now)
    #   payload[:exp] = exp.to_i
    #   JWT.encode(payload, SECRET_KEY)
    # end

    def self.encode(payload, exp = 7.days.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end
  
    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new decoded
    end
end