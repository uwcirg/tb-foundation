class Channel < ApplicationRecord
    enum category: { Default: 0, SiteGroup: 1, Patient: 2, StudyGroup: 3}
    has_many :messages, dependent: :destroy
    has_many :messaging_notifications, dependent: :destroy

    belongs_to :user, optional: true
    validates :title, presence: true, length: {maximum: 50}
    validates :subtitle, length: {maximum: 250}

    after_commit :create_unread_messages_async, on: :create

    scope :active, -> { where(:status => ("Active")) }

    scope :expert_access, -> (expert){joins(:user).where(is_private: true, users: { type: "Practitioner" }).or(Channel.joins(:user).where(is_private: false)).order(:created_at)}

    def create_unread_messages
        User.all.map do |u|
            if(u.available_channels.where(id: self.id).exists?)
                begin
                    u.messaging_notifications.create!(channel_id: self.id, user_id: u.id )
                rescue
                    next
                end
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

    def user_type
        if(not user.nil?)
            return user.type
        end
        return "System"
    end

    def is_site_channel
        self.category == "SiteGroup"
    end

    def public?
        !self.is_private 
    end

    private

    def create_unread_messages_async
        ::NewChannelNotificationWorker.perform_async(self.id)
    end


end
