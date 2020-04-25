class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel, counter_cache: true
    after_create :update_unread_messages

    def update_unread_messages

        # Notification.where(channel_id: self.channel_id).map do |notification|
        #     if(notification.user.push_url.present?)
        #         notification.user.send_push_to_user(self.channel.title,self.body)
        #     end
        # end

        #Update all users that have a thing for this channel

        
        # UnreadMessage.find_each() do |unread| 
            
        #     unread.update_attributes(
        #                         number_unread: unread.number_unread + 1
        #                        )
        #   end




    end

end
