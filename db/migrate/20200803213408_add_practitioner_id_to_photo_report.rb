class AddPractitionerIdToPhotoReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :photo_reports, :practitioner, foreign_key: { to_table: :users }
  end
end
