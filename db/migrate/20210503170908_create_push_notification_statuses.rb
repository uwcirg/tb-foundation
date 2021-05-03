class CreatePushNotificationStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :push_notification_statuses do |t|
      t.boolean :sent_successfully
      t.boolean :delivered_successfully
      t.boolean :clicked
      t.datetime :clicked_at

      t.timestamps
    end
  end
end
