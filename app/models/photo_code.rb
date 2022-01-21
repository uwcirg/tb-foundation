class PhotoCode < ApplicationRecord
    validates :code, presence: true
    validates :title, presence: true
    validates :description, presence: true

end