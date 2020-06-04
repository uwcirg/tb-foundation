class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :full_name, :id, :date

    def url
        object.get_url
    end

    def photo_id
        object.id
    end

    def full_name
        object.patient.full_name
    end

    def id
        object.patient.id
    end

    def date
        object.daily_report.date
    end



end