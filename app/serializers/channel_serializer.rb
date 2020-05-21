class ChannelSerializer < ActiveModel::Serializer
    
    attributes :id, :title, :subtitle, :messages_count, :is_private, :updated_at, :user_id,:last_message_time, :test

    def unread_messages
        return(object.messages_count - MessagingNotification.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

    def last_message_time
        message = object.messages.last
        if(!message.nil?)
            return(message.created_at)
        end

        return(object.created_at)

    end

    def test
    return(I18n.t('welcome'))
    end

end