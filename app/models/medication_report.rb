class MedicationReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  belongs_to :user
  #has_one :daily_report

end
