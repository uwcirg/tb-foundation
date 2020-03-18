class Channel < ApplicationRecord
    has_many :messages
    belongs_to :user
    validates :title, presence: true, uniqueness: true  

    after_create :create_notifications

    #When Creating a new channel initalize notifications for that channel
    #TODO allow notifications for coordinator on private channel
    def create_notifications
        User.all.map do |u| 
            if(!self.is_private || self.user_id == u.id || self.user.practitioner_id == u.id)
                u.notifications.create!(channel_id: self.id, user_id: u.id, push_subscription: true )
            end
        end
    end
end
