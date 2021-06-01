class AddAdherenceToInfoModel < ActiveRecord::Migration[6.0]
  def change
    add_column :patient_informations, :adherent_days, :integer, default: 0
    add_column :patient_informations, :adherent_photo_days, :integer, default: 0
    add_column :patient_informations, :number_of_photo_requests, :integer, default: 1
    add_column :patient_informations, :requests_updated_at, :datetime, default: Time.now
    add_column :patient_informations, :had_symptom_in_past_week, :boolean, default: false
    add_column :patient_informations, :had_severe_symptom_in_past_week, :boolean, default: false
    add_column :patient_informations, :negative_photo_in_past_week, :boolean, default: false
    add_column :patient_informations, :number_of_conclusive_photos, :integer, default: 0
    add_column :patient_informations, :medication_streak, :integer, default: 0
  end
end
