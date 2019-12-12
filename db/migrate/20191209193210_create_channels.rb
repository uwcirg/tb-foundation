class CreateChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :channels do |t|
      t.string :creator_id, null: false
      t.string :creator_type, null: false
      t.string :title, null: false
      t.string :subtitle
      t.timestamps
    end
    add_index(:channels,["creator_type", "creator_id"])
    #add_foreign_key :channels, :participants, column: :participant_id, primary_key: "uuid"
  end
end
