class AddPhotoToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :photo_path, :string
  end
end
