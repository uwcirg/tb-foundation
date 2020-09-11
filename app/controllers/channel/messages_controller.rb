class Channel::MessagesController < UserController
    before_action :snake_case_params
    before_action :auth_user

    
    def index
        #TODO paginate longer conversations, combined with lazy loading
        channel = relevant_channel
        messages = channel.messages.order("created_at DESC").reverse
        @current_user.update_last_message_seen(channel.id,channel.messages_count)
        render(json: messages, status: :ok)
    end

    def create
        new_message = relevant_channel.messages.create!(message_params.merge(user_id: @current_user.id))
        render(json: new_message.to_json, status: 200)
    end

    private

    def message_params
        params.permit(:body,:photo_path)
    end

    def relevant_channel
        #Current user from before_action, inherited from UserController
        @current_user.available_channels.find(params[:channel_id])
    end
    

  end
  