class CleanupUnusedFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :medication_type, :string
    remove_column :users, :profile_note, :text
  end
end
