class PhotoCodeGroup < ApplicationRecord
    has_many :photo_codes
    validates :group, presence: true, uniqueness: true
end