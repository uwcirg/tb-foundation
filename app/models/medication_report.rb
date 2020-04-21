class MedicationReport < ApplicationRecord
  belongs_to :daily_report, optional: true
  #has_one :daily_report

end
