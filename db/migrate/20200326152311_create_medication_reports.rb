class CreateMedicationReports < ActiveRecord::Migration[6.0]
  def change

    create_table :daily_reports do |t|
      t.belongs_to :user
      t.timestamps
      t.date :date
    end

    create_table :medication_reports do |t|
      t.belongs_to :daily_report
      t.datetime :datetime_taken
      t.boolean :medication_was_taken
      t.text :why_medication_not_taken
      t.timestamps 
    end

    create_table :symptom_reports do |t|
      t.belongs_to :daily_report
      t.datetime :time_medication_taken
      t.boolean :nausea
      t.boolean :redness
      t.boolean :hives
      t.boolean :fever
      t.boolean :appetite_loss
      t.boolean :blurred_vision
      t.boolean :sore_belly
      t.boolean :yellow_coloration
      t.boolean :difficulty_breathing
      t.boolean :facial_swelling
      t.boolean :headache
      t.boolean :dizziness
      t.integer :nausea_rating
      t.text :other
      t.timestamps
    end

    create_table :photo_reports do |t|
      t.belongs_to :daily_report
      t.datetime :captured_at
      t.string :photo_url
    end
  end
end
