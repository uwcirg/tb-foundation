class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|

      #Fundementals
      t.string :password_digest, null: false
      t.boolean :active, null: false, default: true
      t.string :family_name, null: false
      t.string :given_name, null: false
      t.string :managing_organization, null: false
      t.integer :language,  null: false, default: 0

      #Push Notification data
      t.string :push_url
      t.string :push_auth
      t.string :push_p256dh

      #Change based on roll
      t.integer :type, null: false, default: 0
      t.string :email, 
      t.string :phone_number
      t.string :general_practitioner
      t.datetime :treatment_start
    end
  end
end
