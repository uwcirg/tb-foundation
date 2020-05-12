class FixConditionalMessageNotifications < ActiveRecord::Migration[6.0]
  def change
    rename_table  :unread_messages, :messaging_notifications
    add_column :messaging_notifications, :is_subscribed, :boolean, default: true, null: false
    remove_column :messaging_notifications, :push_subscription
  end
end
