class V2::MessagesController < UserController
  before_action :snake_case_params
  before_action :auth_user

  def index
    #TODO paginate longer conversations, combined with lazy loading
    channel = relevant_channel

    if(params[:first_message_id])
      messages = channel.messages.where("id < ?", params[:first_message_id] || 0).includes(:user)
    else
      messages = channel.messages.where("id > ?", params[:last_message_id] || 0).includes(:user)
    end


    if (@current_user.patient?)
      messages = messages.where(is_hidden: false)
    end

    messages = messages.order("created_at").last(20)

    @current_user.update_last_message_seen(channel.id, channel.messages_count)

    render(json: messages, current_user: @current_user, status: :ok)
  end

  def create
    new_message = relevant_channel.messages.create!(message_params.merge(user_id: @current_user.id))
    render(json: new_message.to_json, status: 200)
  end

  def update
    message = Message.find(update_params[:id])
    authorize message

    if (message.channel.is_private && !message.channel.is_site_channel)
      render(json: { error: "Cannot hide messages in non public discussions" }, status: 422)
      return
    end

    message.update!(update_params)
    render(json: message, status: :ok)
  end

  private

  def update_params
    params.permit(:is_hidden, :id)
  end

  def message_params
    params.permit(:body, :photo_path)
  end

  def relevant_channel
    policy_scope(Channel).find(params[:channel_id])
  end

  # #Decide whether to send hidden messages or not
  # def relevant_messages
  #   type = @current_user.type
  #   if (type === "Practitioner" || type === "Admin")
  #     return channel.messages.where("id > ?", params[:last_message_id]).where(:is_hidden).order("created_at DESC")
  #   end
  # end
end
