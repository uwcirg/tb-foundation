class UnreadMessageSerializer < ActiveModel::Serializer
    
    attributes :read_message_count, :channel_id, :unread_messages
    

end