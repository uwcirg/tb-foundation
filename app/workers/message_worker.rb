class MessageWorker
    include Sidekiq::Worker
    # call this from the channel controller ::IncrementCountWorker.perform_async(params[:post_id])
    def perform(channel_id, user_id)
        entry = UnreadMessage.where(channel_id: channel_id, user_id: user_id).first
        entry 
    end
  end