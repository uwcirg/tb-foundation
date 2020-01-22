class AddLabImage < ActiveRecord::Migration[6.0]
  def change
    create_table :lab_tests do |t|
      t.bigint :test_id
      t.string :description, null: false
      t.string :photo_url, null: false
      t.boolean :is_positive, null: false
      t.boolean :test_was_run, null: false
      t.bigint :minutes_since_test, null: false
      t.timestamps
    end
  end
end
