class Reminder < ApplicationRecord
    belongs_to :patient 
    enum category: { check_in: 0, medication_pickup: 1, sputum_test: 2, other: 3}
end