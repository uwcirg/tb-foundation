class CreateUnreadMessages < ActiveRecord::Migration[6.0]
  def change
    rename_table :notifications, :unread_messages
    add_column :unread_messages, :number_unread, :bigint, :default => 0
  end
end
