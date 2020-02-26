class AddPrivateChannels < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :is_private, :boolean, null: false, default: false
  end
end
