class AddPhotoSkippingToPhotoReport < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reports, :photo_was_skipped, :boolean, default: false
    add_column :photo_reports, :why_photo_was_skipped, :text
  end
end
