class DataScientist < User

  validates :type, inclusion: { in: ["DataScientist"] }
  validates :email, presence: true

end