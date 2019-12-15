class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.bigint :user_id, null: false
      t.string :title, null: false
      t.string :subtitle
      t.timestamps
    end
    add_foreign_key :channels, :users, column: :user_id, primary_key: "id"
  end
end
