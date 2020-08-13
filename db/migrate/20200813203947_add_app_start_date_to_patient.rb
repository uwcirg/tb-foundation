class AddAppStartDateToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :app_start, :datetime

    reversible do |dir|
      dir.up { Patient.update_all('app_start = treatment_start') }
    end
  end
end
