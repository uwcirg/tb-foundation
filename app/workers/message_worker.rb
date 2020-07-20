class MessageWorker
    include Sidekiq::Worker
    # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
    #Dont retry if any of them fail ( will send duplicate notifications)
    sidekiq_options retry: 0
    def perform(channel_id, channel_title,sender_id)

        MessagingNotification.where(channel_id: channel_id, is_subscribed: true).each do |item| 

            if(item.user_id != sender_id)
                puts("Sending push notification to #{item.user.given_name} for new message in #{channel_title}")
                puts("Live Reload Test")
                item.user.send_push_to_user("Nuevos Mensajes", "#{channel_title} tiene un nuevo mensaje", "/messaging", "messaging")
            else
                puts("Not sending to the sender")
            end
        end
    end
  end