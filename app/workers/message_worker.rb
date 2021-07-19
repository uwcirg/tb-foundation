class MessageWorker
  include Sidekiq::Worker
  # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
  #Dont retry if any of them fail ( will send duplicate notifications)
  sidekiq_options retry: 0

  def perform(channel_id, channel_title, sender_id)
    is_public = Channel.find(channel_id).public?

    MessagingNotification.where(channel_id: channel_id, is_subscribed: true).each do |item|
      is_not_user_who_sent = item.user_id != sender_id
      recipient_is_patient_and_channel_is_public = item.user.patient? && is_public
      notificaiton_should_be_sent = is_not_user_who_sent && !recipient_is_patient_and_channel_is_public

      if (notificaiton_should_be_sent)
        item.user.send_push_to_user("Nuevos Mensajes", "#{channel_title} tiene un nuevo mensaje", "/messaging/channel/#{channel_id}", "Messaging")
      end
    end
  end
end
