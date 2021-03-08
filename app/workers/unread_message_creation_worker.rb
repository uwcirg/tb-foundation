class UnreadMessageCreationWorker
    include Sidekiq::Worker

    def perform(user_id)
        puts("Creating Unread Messages for user #{user_id}")
        User.find(user_id).create_unread_messages
    end
    
  end