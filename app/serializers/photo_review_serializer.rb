class PhotoReviewSerializer < ActiveModel::Serializer
    attributes :photo_report_id, :test_line_review, 
    :control_line_review, :control_color_id, :test_color_id,
    :test_strip_id,:control_color_value, :test_color_value,
    :test_strip_version_id, :photo_url

    def photo_url
        object.photo_report.get_url
    end

end