class PhotoReviewSerializer < ActiveModel::Serializer
    attributes :id, :photo_id

    def photo_id
        object.photo_report_id
    end
end