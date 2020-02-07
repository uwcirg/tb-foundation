class TempAccount < ApplicationRecord

    validates :phone_number, presence: true, uniqueness: true
    validates :given_name, presence: true
    validates :family_name, presence: true

end