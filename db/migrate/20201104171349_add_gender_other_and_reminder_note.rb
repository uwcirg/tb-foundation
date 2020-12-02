class AddGenderOtherAndReminderNote < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :gender_other, :string
    add_column :reminders, :note, :text
  end
end
