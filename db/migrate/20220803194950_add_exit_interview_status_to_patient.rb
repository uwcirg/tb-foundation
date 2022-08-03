class AddExitInterviewStatusToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referred_for_exit_interview, :boolean, default: false
  end
end
