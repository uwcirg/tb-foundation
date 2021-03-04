class AddTemporaryPasswordToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :has_temp_password, :boolean, default: false
  end
end
