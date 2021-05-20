class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :patient_id, :date, :created_at

    def url
        object.get_url
    end

    def photo_id
        object.id
    end

    def patient_id
        object.patient.id
    end

    def date
        object.daily_report ? object.daily_report.date : nil
    end

    def created_at
        object.daily_report ? object.daily_report.created_at : nil
    end



end