class ChannelController < UserController
  #before_action :auth_any_user, :except => [:cors_preflight]
  #TODO: make sure each user level has access to only thier proper functions
  before_action :auth_user

  def get_unread_message_numbers
    #unread = UnreadMessage.where(user_id: @current_user.id )
    unread = UnreadMessage.where(user_id: @current_user.id)
    render(json: unread,status: 200)
   
  end

  #Message CRUG
  def new_channel
    #chan = Channel.create!(title: params[:title], subtitle: params[:subtitle], creator_id: @current_user.uuid, creator_type: "Participant")
    chan = @current_user.channels.create!(title: params[:title], subtitle: params[:subtitle])
    render(json: chan.to_json, status: 200)
  end

  def all_channels
    #response = Channel.where(is_private: false).or(Channel.where(is_private: true, user_id: @current_user.id)).sort_by &:created_at
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
    #TODO Make sure patient is one of practitionser, so that not all practitioners have access

    if (!channel.is_private || (channel.user_id == @current_user.id) || (@current_user.type == "Practitioner"))
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
