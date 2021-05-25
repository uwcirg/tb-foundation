class AddAdherenceToInfoModel < ActiveRecord::Migration[6.0]
  def change
    add_column :patient_informations, :adherent_days, :integer, default: 0
    add_column :patient_informations, :adherent_photo_days, :integer, default: 0
    add_column :patient_informations, :number_of_photo_requests, :integer, default: 0
    add_column :patient_informations, :adherence_updated_at, :datetime, default: Time.now
  end
end
