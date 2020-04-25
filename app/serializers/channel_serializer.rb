class ChannelSerializer < ActiveModel::Serializer
    
    attributes :id, :unread_messages, :title, :messages_count

    def unread_messages
        return(object.messages_count - UnreadMessage.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

end