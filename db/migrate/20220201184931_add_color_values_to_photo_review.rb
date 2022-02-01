class AddColorValuesToPhotoReview < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reviews, :test_color_value, :string, null: true
    add_column :photo_reviews, :control_color_value, :string, null: true
  end
end
