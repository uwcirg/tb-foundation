class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel
    after_create :send_push_if_subscribed

    def send_push_if_subscribed
        Notification.where(channel_id: self.channel_id).map do |notification|
            if(notification.user.push_url.present?)
                notification.user.send_push_to_user(self.channel.title,self.body)
            end
        end
    end

end
