class AddCodingForPhotoReports < ActiveRecord::Migration[6.0]
  def change

    create_table :photo_codes do |t|
      t.decimal :code
      t.string :title
      t.text :description
      t.timestamps
    end

    create_table :photo_colors do |t|
      t.string :name
      t.timestamps
    end


    create_table :code_applications do |t|
      t.belongs_to :bio_engineer, foreign_key: { to_table: :users }
      t.references :photo_code
      t.references :photo_report
      t.text :description
      t.timestamps
    end

    add_index :photo_codes, :code, unique: true
    add_index :code_applications, [:photo_code_id, :photo_report_id], unique: true, name: :photo_coding_index

    add_column :photo_reports, :test_line_review, :integer, default: 0
    add_column :photo_reports, :control_line_review, :integer, default: 0
    add_column :photo_reports, :review_complete, :boolean, default: false
    add_reference :photo_reports, :photo_colors, index: true, null: true
    add_reference :photo_reports, :reviewer, null: true, foreign_key: {to_table: :users}

  end
end
