class UnreadMessageCreationWorker
    include Sidekiq::Worker

    def perform(user_id)
        User.find(user_id).create_unread_messages
    end
    
  end