module AuthHelper

    def cookie_for_user(user)
      # The argument 'user' should be a hash that includes the params 'email' and 'password'.
      post '/auth/',
        params: { email: user[:email] || nil,phone_number: user[:phone_number] || nil, password: user[:password], userType: user[:type] },
        as: :json
      # The three categories below are the ones you need as authentication headers.
      return response.cookies['jwt']
    end
  end