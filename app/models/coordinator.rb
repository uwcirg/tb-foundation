class Coordinator < User

  validates :type, inclusion: { in: ["Coordinator"] }
  validates :email, presence: true

end