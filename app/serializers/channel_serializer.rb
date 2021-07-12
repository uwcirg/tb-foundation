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
    :is_site_channel,
    :first_message_id,
    :creator_is_archived

    def unread_messages
        return(object.messages_count - MessagingNotification.where(user_id: @instance_options[:user_id],channel_id: object.id ).first.read_message_count)
    end

    def title
        if(@instance_options[:requesting_user_type] == "Expert" &&  object.title == "tb-expert-chat")
            return object.user.full_name
        end
        return object.title
    end

    def first_message_id
        object.messages.count > 0 ? object.messages.first.id : nil
    end

    def is_private
        return object.is_private  && !object.is_site_channel
    end

    def creator_is_archived
        !object.user.nil? && object.user.patient? && object.user.status == "Archived"
    end

end