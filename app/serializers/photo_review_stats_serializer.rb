class PhotoReviewStatsSerializer < ActiveModel::Serializer
    attributes :number_of_reviewed_photos, :number_of_photos_total, :percentage_reviewed
end