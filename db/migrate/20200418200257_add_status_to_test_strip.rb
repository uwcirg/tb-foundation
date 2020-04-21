class AddStatusToTestStrip < ActiveRecord::Migration[6.0]
  def change
    add_column :temp_accounts, :activated, :boolean, :default => false
    add_column :photo_reports, :approved, :boolean
    add_column :photo_reports, :approval_timestamp, :datetime
  end
end
