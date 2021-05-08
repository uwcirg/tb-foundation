class PatientInformation < ApplicationRecord
    belongs_to :patient

    # t.datetime :datetime_created
    # t.datetime :datetime_activated
    # t.integer :reminders_since_last_report
    # t.references :patient, foreign_key: { to_table: :users }, null: false
end
