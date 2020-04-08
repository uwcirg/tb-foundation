class AddNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :daily_notifications do |t|
      t.boolean :active
      t.time :time
      t.belongs_to :user
    end

    create_table :notificaiton_status do |t|
      t.datetime :time_delivered
      t.datetime :time_interacted
      t.belongs_to :daily_notification
    end


  end
end
