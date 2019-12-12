class Coordinator < ApplicationRecord
  has_many :notes, as: :author, dependent: :destroy

  has_many :messages, as: :creator
  has_many :channels, as: :creator

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true

  def as_json(*args)
    {
      uuid: uuid,
      name: name,
      email: email,
      participants: Participant.all.map(&:summary),
      resolutions: Resolution.all.as_json,
    }
  end

end
