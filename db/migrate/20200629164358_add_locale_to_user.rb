class AddLocaleToUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :language, :integer
    add_column :users, :locale, :integer, default: 1
  end
end
