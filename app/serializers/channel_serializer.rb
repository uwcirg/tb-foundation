class ChannelSerializer < ActiveModel::Serializer
    
    attributes :id, :unread_messages, :title, :subtitle, :messages_count, :is_private, :updated_at, :user_id,:last_message_time

    def unread_messages
        return(object.messages_count - UnreadMessage.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

    def last_message_time
        return(object.messages.last.created_at)
    end

end