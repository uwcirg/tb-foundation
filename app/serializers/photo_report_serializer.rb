class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :patient_id, :date, :created_at, :site, :photo_was_skipped, :why_photo_was_skipped, :back_submission, :requester_id

    # has_many :photo_codes

    def requester_id
        @instance_options[:current_user].full_name || "Unknown"
    end

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
        if(object.created_at)
            return object.created_at
        end
        object.daily_report ? object.daily_report.created_at : nil
    end

    def site
        object.patient.organization.title
    end

end