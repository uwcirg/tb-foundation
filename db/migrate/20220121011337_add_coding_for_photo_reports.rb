class AddCodingForPhotoReports < ActiveRecord::Migration[6.0]
  def change
    create_table :photo_codes do |t|
      t.integer :code
      t.string :title
      t.text :description
      t.timestamps
    end

    create_table :code_applications do |t|
      t.belongs_to :bio_engineer, foreign_key: { to_table: :users }
      t.references :photo_review_code
      t.references :photo_report
      t.text :description
      t.timestamps
    end

    add_index :code_applications, [:photo_review_code_id, :photo_report_id], unique: true, name: :photo_coding_index
  end
end
