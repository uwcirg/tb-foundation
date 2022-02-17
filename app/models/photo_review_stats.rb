class PhotoReviewStats < ActiveModelSerializers::Model

    def initialize(user)
        @bio_e = user
    end

    def number_of_reviewed_photos
        @bio_e.photo_reviews.count
    end
    
    def number_of_photos_total
        PhotoReport.reviewable.count
    end

    def percentage_reviewed
       "#{(number_of_reviewed_photos.to_f / number_of_photos_total.to_f * 100).round}%"
    end
  
  end
  