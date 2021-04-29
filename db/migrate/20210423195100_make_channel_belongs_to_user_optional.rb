class MakeChannelBelongsToUserOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null :channels, :user_id, true
  end
end
