class AddTempAccount < ActiveRecord::Migration[6.0]
  def change
    create_table :temp_accounts do |t|
      t.bigint :phone_number, null: false
      t.string :given_name, null: false
      t.string :family_name, null: false
      t.date :treatment_start
      t.string :code_digest, null: false
      t.string :organization, null: false
      t.timestamps
    end
    create_table :organizations do |t|
      t.string :title, null: false
    end
    add_index :organizations, :title, unique: true
    add_foreign_key :temp_accounts, :organizations, column: :organization, primary_key: "title"
  end
end
