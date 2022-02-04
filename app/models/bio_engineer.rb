class BioEngineer < User

    has_many :photo_reviews

    validates :type, inclusion: { in: ["BioEngineer"] }
    validates :email, presence: true

end