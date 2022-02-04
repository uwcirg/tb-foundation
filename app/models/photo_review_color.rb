class PhotoReviewColor < ApplicationRecord
    validates :name, presence: true, uniqueness: true

    has_many :photo_reviews

end