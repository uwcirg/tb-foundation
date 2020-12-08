class PhotoDay < ApplicationRecord
    belongs_to :patient
    scope :requested, -> { where('date <= CURRENT_DATE') }
end
  