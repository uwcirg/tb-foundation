class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel, counter_cache: true
    after_create :send_notifications

    attr_accessor :skip_notify
    skip_callback :create, :after, :send_notifications, if: :skip_notify

    def send_notifications

        puts("Message Callback")
        ::MessageWorker.perform_async(self.channel_id,self.channel.title,self.user_id)
        
        # Notification.where(channel_id: self.channel_id).map do |notification|
        #     if(notification.user.push_url.present?)
        #         notification.user.send_push_to_user(self.channel.title,self.body)
        #     end
        # end
        
    end

end
