class Messaging::UnreadMessagesController < UserController
  before_action :auth_user

  def index
    unread = ActiveModel::SerializableResource.new(MessagingNotification.where(user_id: @current_user.id)).serializable_hash

    channel_hash = {}
    total = 0
    unread.each do |item|
      total += item[:unreadMessages]
      channel_hash[item[:channelId]] = item
    end

    hash = {
      channels: channel_hash,
      total: total
    }
    render(json: hash, status: 200)
  end
end
