class MessageWorker
  include Sidekiq::Worker
  # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
  #Dont retry if any of them fail ( will send duplicate notifications)
  sidekiq_options retry: 0

  def perform(channel_id, channel_title, sender_id)
    is_public = Channel.find(channel_id).public?

    MessagingNotification.where(channel_id: channel_id, is_subscribed: true).each do |item|
      should_be_sent = (item.user_id != sender_id) && !(item.user.patient? && is_public)
      return if (!should_be_sent)
      notifer = NotifyUser.new(item.user)
      is_public ? notifer.public_message_alert(channel_title, channel_id) : notifer.private_message_alert(channel_id)
    end
  end
end
