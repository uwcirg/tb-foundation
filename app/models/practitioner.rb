class Practitioner < User

    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

end