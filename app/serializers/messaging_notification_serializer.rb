class MessagingNotificationSerializer < ActiveModel::Serializer
    
    attributes :read_message_count, :channel_id, :unread_messages, :is_private, :is_site_channel

    def unread_messages
        return(Channel.find(object.channel_id).messages_count - object.read_message_count)
    end

    def is_private
        object.channel.is_private
    end
    
    def is_site_channel
        object.channel.is_site_channel
    end

end