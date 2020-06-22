class ChannelController < UserController

  #TODO: make sure each user level has access to only thier proper functions
  before_action :auth_user

  def get_unread_message_numbers
    unread = ActiveModel::SerializableResource.new(MessagingNotification.where(user_id: @current_user.id )).serializable_hash

    channel_hash = {}
    total = 0;
    unread.each do |item|
      total += item[:unreadMessages]
      channel_hash[item[:channelId]] = item
    end

    hash = {
      channels: channel_hash,
      total: total
    }
    render(json: hash,status: 200)
   
  end

  def new_channel
    chan = @current_user.channels.create!(title: params[:title], subtitle: params[:subtitle])
    render(json: chan.to_json, status: 200)
  end

  def all_channels
    response = @current_user.user_specific_channels
    render(json: response, user_id: @current_user.id, status: 200)
  end

  def post_message
    newMessage = @current_user.messages.create!(body: params[:body], channel_id: params["channelID"], user_id: @current_user.id)
    #@current_user.testd
    render(json: newMessage.to_json, status: 200)
  end

  def get_recent_messages
    channel = Channel.find(params["channelID"])
    
    #Allow all user to have access to public channels, limit access to practitioner for private ones
    if (!channel.is_private || (channel.user_id == @current_user.id) || (@current_user.type == "Practitioner" && channel.user.organization_id == @current_user.organization_id))
      if (params.has_key?("lastMessageID"))
        messages = channel.messages.where("id > ?", params["lastMessageID"]).order("created_at")
      else
        messages = channel.messages.order("created_at").limit(100)
      end

      @current_user.update_last_message_seen(channel.id,channel.messages_count)
      render(json: messages.to_json, status: 200)
    else
      render(json: { message: "You are not authorized to access that channels messages." }, status: 401)
    end
  end

  def get_messages_before
    messages = Channel.find(params["channelID"]).messages.where("id < ?", params["messageID"])
    render(json: messages.to_json, status: 200)
  end
end
