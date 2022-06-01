class Reminder < ApplicationRecord
    belongs_to :patient
    belongs_to :creator, class_name: "User"

    # scope :on_or_after, -> date { where("date(datetime) >= ?", date)}
    scope :upcoming, -> {where("datetime > ?", Time.now).order("datetime")}

    enum category: { check_in: 0, medication_pickup: 1, sputum_test: 2, other: 3}

end