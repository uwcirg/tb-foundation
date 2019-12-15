class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.bigint :channel_id
      t.bigint :user_id, null: false
      t.text :body, null: false
      t.timestamps
    end

    add_foreign_key :messages, :channels, column: :channel_id, primary_key: "id"
    #add_foreign_key :messages, :participants, column: :participant_id, primary_key: "uuid"
  end
end
