class NewChannelNotificationWorker
    include Sidekiq::Worker

    def perform(channel_id)
        Channel.find(channel_id).create_unread_messages
    end
    
  end