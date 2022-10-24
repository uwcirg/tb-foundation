class Hugo < User

  validates :type, inclusion: { in: ["Hugo"] }
  validates :email, presence: true

end