class MessageWorker
    include Sidekiq::Worker
    # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
    def perform(channel_id, channel_title,sender_id)

        MessagingNotification.where(channel_id: channel_id, is_subscribed: true).each do |item| 

            if(item.user_id != sender_id)
                puts("Sending push notification to #{item.user.given_name} for new message in #{channel_title}")
                item.user.send_push_to_user("Nuevos Mensajes", "#{channel_title} tiene un nuevo mensaje")
            begin
                puts("Not sending to the sender")
            rescue => exception
                
            else
                
            end
            end
        end
    end
  end