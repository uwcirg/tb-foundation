class MessageWorker
    include Sidekiq::Worker
    # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
    def perform(channel_id, channel_title,sender_id)

        MessagingNotification.where(channel_id: channel_id, is_subscribed: true).each do |item| 

            if(item.user_id != sender_id)
                puts("Sending push to #{item.user.given_name} for new message")
                item.user.send_push_to_user("New Messages", "#{channel_title} has a new message")
            begin
                pust("Not sending to the sender")
            rescue => exception
                
            else
                
            end
            end
        end
    end
  end