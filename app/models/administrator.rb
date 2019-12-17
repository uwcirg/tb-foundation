class Administrator < User

    validates :type, inclusion: { in: ["Administrator"] }
    validates :email, presence: true

end