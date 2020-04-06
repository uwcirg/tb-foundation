class MedicationReport < ApplicationRecord
  #belongs_to :daily_report
  has_one :user, through: :daily_report
end
