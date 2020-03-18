class Practitioner < User
    has_many  :patients
    validates :type, inclusion: { in: ["Practitioner"] }
    validates :email, presence: true

end