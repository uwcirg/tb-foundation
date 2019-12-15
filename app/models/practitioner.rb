class Practitioner < User

    validates :type, inclusion: { in: %w(Practitioner)}
    validates :email, presence: true

end