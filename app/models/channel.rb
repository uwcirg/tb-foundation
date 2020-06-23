class Channel < ApplicationRecord
    has_many :messages
    belongs_to :user
    validates :title, presence: true

    after_create :create_notifications

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


end
