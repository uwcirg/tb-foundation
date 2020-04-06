class AddPractitonerToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :temp_accounts, :practitioner_id, :bigint
    add_foreign_key :temp_accounts, :users, column: :practitioner_id, primary_key: "id"
  end
end
