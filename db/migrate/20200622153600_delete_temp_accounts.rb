class DeleteTempAccounts < ActiveRecord::Migration[6.0]
  def change
    #Enum for account status. Pending => 0, Active => 1, Archived => 2
    add_column :users, :status, :integer, null: false, default: 1
  end
end
