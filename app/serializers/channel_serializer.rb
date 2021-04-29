class ChannelSerializer < ActiveModel::Serializer
    
    attributes :id, 
    :title, 
    :subtitle, 
    :messages_count, 
    :is_private, 
    :updated_at, 
    :user_id,
    :last_message_time,
    :user_type,
    :is_site_channel

    def unread_messages
        return(object.messages_count - MessagingNotification.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

    def title
        
        if(@instance_options[:requesting_user_type] == "Expert" &&  object.title == "tb-expert-chat")
            return object.user.full_name
        elsif()

        end
        return object.title
    end

end