class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.bigint :channel_id
      t.bigint :user_id
      t.bigint :last_message_id
      t.boolean :push_subscription
    end

    add_foreign_key :notifications, :users, column: :user_id, primary_key: "id"
    add_foreign_key :notifications, :channels, column: :channel_id, primary_key: "id"
    add_foreign_key :notifications, :messages, column: :last_message_id, primary_key: "id"
  end
end
