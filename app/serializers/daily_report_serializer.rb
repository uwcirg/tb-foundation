class DailyReportSerializer < ActiveModel::Serializer
    attributes :id, :date, :user_id, :photo_url, :took_medication

    def photo_url
        object.get_photo
    end

    def took_medication
        object.medication_report.medication_was_taken
    end


end