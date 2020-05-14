class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel, counter_cache: true
    after_create :send_notifications

    attr_accessor :skip_notify
    skip_callback :create, :after, :send_notifications, if: :skip_notify

    def send_notifications
        ::MessageWorker.perform_async(self.channel_id,self.channel.title,self.user_id)   
    end

end
