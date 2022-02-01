class AddColorValuesToPhotoReview < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reviews, :testColorValue, :string, null: true
    add_column :photo_reviews, :controlColorValue, :string, null: true
  end
end
