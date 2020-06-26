class CreateContactTracing < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_tracings do |t|
      t.bigint :patient_id, null: false
      t.integer :number_of_contacts
      t.integer :contacts_tested
    end
  end
end
