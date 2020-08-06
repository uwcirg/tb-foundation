class MedicationReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :patient, :foreign_key=> :user_id

  #has_one :daily_report

end
