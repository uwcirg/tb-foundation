class CreatePushNotificationStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :push_notification_statuses do |t|
      t.references :user
      t.boolean :sent_successfully, default: false
      t.boolean :delivered_successfully, default: false
      t.boolean :clicked, default: false
      t.datetime :clicked_at
      t.integer :notification_type

      t.timestamps
    end
  end
end
