class UnreadMessageSerializer < ActiveModel::Serializer
    
    attributes :read_message_count, :channel_id, :unread_messages

    def unread_messages
        return(Channel.find(object.channel_id).messages_count - object.read_message_count)
    end
    

end