class AddColumnsToParticipant < ActiveRecord::Migration[6.0]
  def change
    add_column :participants, :push_url, :string
    add_column :participants, :push_auth, :string
    add_column :participants, :push_p256dh, :string
  end
end
