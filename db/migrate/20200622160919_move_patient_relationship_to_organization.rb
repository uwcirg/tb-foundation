class MovePatientRelationshipToOrganization < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :practitioner_id, :integer
    remove_column :users, :managing_organization, :string
    add_reference :users, :organization, null: false, default: 1
  end
end
