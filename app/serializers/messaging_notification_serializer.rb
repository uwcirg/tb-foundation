class MessagingNotificationSerializer < ActiveModel::Serializer
    
    attributes :read_message_count, :channel_id, :unread_messages, :is_private

    def unread_messages
        return(Channel.find(object.channel_id).messages_count - object.read_message_count)
    end

    def is_private
        object.channel.is_private
    end
    

end