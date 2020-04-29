class AddPatientMilestones < ActiveRecord::Migration[6.0]
  def change
    create_table :milestones do |t|
      t.datetime :datetime
      t.belongs_to :user
      t.boolean :all_day
      t.string :location
      t.string :title
    end
  end
end
