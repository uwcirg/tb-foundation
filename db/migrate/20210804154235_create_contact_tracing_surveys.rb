class CreateContactTracingSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_tracing_surveys do |t|
      t.integer :number_of_contacts
      t.integer :number_of_contacts_tested
      t.references :patient, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
