class AddTreatmentEndDate < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :treatment_end_date, :date
  end
end
