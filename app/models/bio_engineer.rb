class BioEngineer < User

    validates :type, inclusion: { in: ["BioEngineer"] }
    validates :email, presence: true

end