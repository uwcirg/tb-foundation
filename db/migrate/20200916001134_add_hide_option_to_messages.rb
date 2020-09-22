class AddHideOptionToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :is_hidden, :boolean, default: false
  end
end
