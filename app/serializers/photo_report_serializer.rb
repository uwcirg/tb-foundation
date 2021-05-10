class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :patient_id, :date, :created_at

    def url
        object.get_url
    end

    def photo_id
        object.id
    end

    # def full_name
    #     object.patient.full_name
    # end

    def patient_id
        object.patient.id
    end

    def date
        object.daily_report.date
    end

    def created_at
        object.daily_report.created_at
    end



end