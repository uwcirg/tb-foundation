class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel, counter_cache: true
    after_create :send_notifications

    attr_accessor :skip_notify
    skip_callback :create, :after, :send_notifications, if: :skip_notify

    scope :get_photo_urls, -> { where.not(photo_path: nil).map(&:presigned_url) } 
    
    def presigned_url
        return FileHandler.new(Message.photo_bucket, self.photo_path).get_presigned_download_url
    end

    def self.photo_bucket
        return "messaging-photos"
    end

    def send_notifications
        ::MessageWorker.perform_async(self.channel_id,self.channel.title,self.user_id)   
    end

end
