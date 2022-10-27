class AddIndonesianSymptoms < ActiveRecord::Migration[6.0]
  def change
    add_column :symptom_reports, :vertigo, :boolean
    add_column :symptom_reports, :confusion, :boolean
    add_column :symptom_reports, :oliguria, :boolean
    add_column :symptom_reports, :joint_pain, :boolean
    add_column :symptom_reports, :burning_or_numbness, :boolean
    add_column :symptom_reports, :flu_symptoms, :boolean
    add_column :symptom_reports, :red_urine, :boolean
    add_column :symptom_reports, :sleepy, :boolean
  end
end
