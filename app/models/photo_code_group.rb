class PhotoCodeGroup < ApplicationRecord
    validates :group, presence: true, uniqueness: true
end