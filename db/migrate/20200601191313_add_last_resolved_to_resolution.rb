class AddLastResolvedToResolution < ActiveRecord::Migration[6.0]
  def change
    add_column :resolutions, :resolved_at, :datetime
    remove_index :resolutions, [:practitioner_id, :patient_id,:kind]
    add_index :resolutions, [:practitioner_id, :patient_id,:kind]
  end
end
