class AddPushClientPermissionToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :push_client_permission, :string
    add_column :users, :push_subscription_updated_at, :datetime
  end
end
