module AuthHelper

    def cookie_for_user(user)
      # The argument 'user' should be a hash that includes the params 'email' and 'password'.
      post '/auth/',
        params: { identifier: user[:email] || user[:phone_number], password: user[:password], userType: user[:type] },
        as: :json
      # The three categories below are the ones you need as authentication headers.
      return response.cookies['jwt']
    end
  end