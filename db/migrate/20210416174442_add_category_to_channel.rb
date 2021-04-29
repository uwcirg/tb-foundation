class AddCategoryToChannel < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :category, :integer, default: 0
  end
end
