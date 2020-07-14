class ChannelSerializer < ActiveModel::Serializer
    
    attributes :id, :title, :subtitle, :messages_count, :is_private, :updated_at, :user_id,:last_message_time

    def unread_messages
        return(object.messages_count - MessagingNotification.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

end