class Messaging::ChannelsController < UserController

    before_action :auth_user

    def index
        render(json: @current_user.available_channels, status: :ok)
    end 


  end
  