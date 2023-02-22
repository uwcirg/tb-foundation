class Message < ApplicationRecord
    belongs_to :user
    belongs_to :channel, counter_cache: true
    after_create :send_notifications

    attr_accessor :skip_notify
    skip_callback :create, :after, :send_notifications, if: :skip_notify

    def self.photo_bucket
        return "messaging-photos"
    end

    def send_notifications
        ::MessageWorker.perform_async(self.channel_id,self.channel.title,self.user_id)   
    end

    # Get the presigned url for the photo from s3 bucket if photos are sent through message
    def presigned_url
        if self.photo_path != nil
            return FileHandler.new(Message.photo_bucket, self.photo_path).get_presigned_download_url
        end
    end
end
