class AddAdherenceToInfoModel < ActiveRecord::Migration[6.0]
  def change
    add_column :patient_informations, :adherent_days, :integer, default: 0
    add_column :patient_informations, :adherent_photo_days, :integer, default: 0
    add_column :patient_informations, :number_of_photo_requests, :integer, default: 1
    add_column :patient_informations, :requests_updated_at, :datetime, default: Time.now
    add_column :patient_informations, :symptoms_in_past_week, :integer, default: 0
    add_column :patient_informations, :severe_symptoms_in_past_week, :integer, default: 0
  end
end
