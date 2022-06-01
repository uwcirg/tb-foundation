class AddCreatorToReminders < ActiveRecord::Migration[6.0]
  def change
    add_reference :reminders, :creator, foreign_key: { to_table: :users}
  end
end
