class AddPractitionerReferenceToPatient < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :general_practitioner, :string
    add_reference :users, :practitioner, foreign_key: { to_table: :users }
    add_column :users, :medication_schedule, :string
    #add_foreign_key :users, :users, cl
  end

end
