class AddMessageCountToChannel < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :messages_count, :integer, default: 0, null: false
    add_column :unread_messages, :read_message_count, :integer, default: 0, null: false
    remove_column :unread_messages, :number_unread
  end
end
