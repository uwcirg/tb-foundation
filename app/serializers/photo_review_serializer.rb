class PhotoReviewSerializer < ActiveModel::Serializer
    attributes :id, :photo_report_id, :test_line_review, 
    :control_line_review, :control_color_id, :test_color_id,
    :test_strip_id,:control_color_value, :test_color_value,
    :test_strip_version_id, :test_strip_version_number, :photo_url

    has_many :code_applications

    def test_strip_version_number
        object.test_strip_version ? object.test_strip_version.version : nil 
    end

    def photo_url
        object.photo_report.get_url
    end

end