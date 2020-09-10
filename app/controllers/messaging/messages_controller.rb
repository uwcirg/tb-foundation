class Messaging::MessagesController < UserController


    def index
        auth_user
        render(json: @current_user.available_channels.find(params[:channel_id]).messages.limit(10), status: :ok)
    end 

    private

    

  end
  