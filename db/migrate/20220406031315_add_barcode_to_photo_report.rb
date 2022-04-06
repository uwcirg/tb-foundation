class AddBarcodeToPhotoReport < ActiveRecord::Migration[6.0]
  def change
    add_column :photo_reports, :auto_detected_barcode, :integer,  null: true
  end
end
