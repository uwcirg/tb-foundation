class AddCodingForPhotoReports < ActiveRecord::Migration[6.0]
  def change

    create_table :photo_code_groups do |t|
      t.integer :group_code
      t.string :group
      t.timestamps
    end

    add_index :photo_code_groups, :group_code, unique: true

    create_table :photo_codes do |t|
      t.belongs_to :photo_code_group
      t.integer :sub_group_code
      t.string :title
      t.text :description
      t.timestamps
    end

    add_index :photo_codes, [:photo_code_group_id, :sub_group_code], unique: true, name: :photo_coding_definitions_index

    create_table :photo_review_colors do |t|
      t.string :name
      t.timestamps
    end

    create_table :test_strip_versions do |t|
      t.integer :version
      t.text :description
      t.text :id_range_description
      t.date  :shipment_date
      t.timestamps
    end

    create_table :photo_reviews do |t|
      t.belongs_to :bio_engineer, foreign_key: { to_table: :users }
      t.belongs_to :photo_report
      t.belongs_to :test_strip_version, null: true

      t.integer :test_line_review, default: 0
      t.integer :control_line_review, default: 0

      t.references :control_line_color, null: true
      t.references :test_line_color, null: true

      t.timestamps
    end

    add_foreign_key :photo_reviews, :photo_review_colors, column: :control_line_color_id, primary_key: :id
    add_foreign_key :photo_reviews, :photo_review_colors, column: :test_line_color_id, primary_key: :id

    create_table :code_applications do |t|
      t.references :photo_code
      t.references :photo_review
      t.text :description
      t.timestamps
    end

    add_index :test_strip_versions, :version, unique: true

    add_index :code_applications, [:photo_code_id, :photo_review_id], unique: true, name: :photo_coding_index


  end
end
