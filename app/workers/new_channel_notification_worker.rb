class NewChannelNotificationWorker
    include Sidekiq::Worker

    def perform(channel_id)
        Channel.find(channel_id).create_notifications
    end
    
  end