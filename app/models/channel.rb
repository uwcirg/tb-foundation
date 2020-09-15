class Channel < ApplicationRecord
    has_many :messages, dependent: :destroy
    #Enable this to allow deleting of these records
    #has_many :messaging_notifications, dependent: :destroy

    belongs_to :user
    validates :title, presence: true, length: {maximum: 50}
    validates :subtitle, length: {maximum: 250}

    after_create :create_notifications

    scope :active, -> { where(:status => ("Active")) }

    #When Creating a new channel initalize notifications for that channel
    #TODO allow notifications for coordinator on private channel
    #TODO move this to a worker becuase it will be intensive, might be a better method to update
    def create_notifications
        User.all.map do |u| 
            if(!self.is_private || self.user_id == u.id || (u.type == "Practitioner" && (self.user.organization == u.organization)))
                u.messaging_notifications.create!(channel_id: self.id, user_id: u.id )
            end
        end
    end

    def last_message_time
        message = self.messages.last
        if(!message.nil?)
            return(message.created_at)
        end

        return(self.created_at)

    end


end
