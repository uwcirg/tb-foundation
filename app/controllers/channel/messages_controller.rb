class Channel::MessagesController < UserController
  before_action :snake_case_params
  before_action :auth_user

  def index
    #TODO paginate longer conversations, combined with lazy loading
    channel = relevant_channel

    messages = channel.messages.where("id > ?", params[:last_message_id] || 0).includes(:user)
    messages = messages.order("created_at")
    if(@current_user.type === "Patient")
        messages = messages.where(is_hidden: false)
    end
    @current_user.update_last_message_seen(channel.id, channel.messages_count)

    render(json: messages, status: :ok)
  end

  def create
    new_message = relevant_channel.messages.create!(message_params.merge(user_id: @current_user.id))
    render(json: new_message.to_json, status: 200)
  end

  private

  def message_params
    params.permit(:body, :photo_path)
  end

  def relevant_channel
    #Current user from before_action, inherited from UserController
    @current_user.available_channels.find(params[:channel_id])
  end

  #Decide whether to send hidden messages or not
  def relevant_messages
    type = @current_user.type
    if (type === "Practitioner" || type === "Admin")
      return channel.messages.where("id > ?", params[:last_message_id]).where(:is_hidden).order("created_at DESC")
    end
  end
end
