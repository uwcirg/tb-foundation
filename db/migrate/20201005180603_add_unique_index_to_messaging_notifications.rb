class AddUniqueIndexToMessagingNotifications < ActiveRecord::Migration[6.0]
  def change
    add_index :messaging_notifications, [:channel_id, :user_id], unique: true
  end
end
