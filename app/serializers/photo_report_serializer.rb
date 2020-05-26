class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :full_name

    def url
        object.get_url
    end

    def photo_id
        object.id
    end

    def full_name
        object.patient.full_name
    end



end