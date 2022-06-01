class Reminder < ApplicationRecord
    belongs_to :patient
    belongs_to :creator, class_name: "User"

    enum category: { check_in: 0, medication_pickup: 1, sputum_test: 2, other: 3}
end