class DailyReportSerializer < ActiveModel::Serializer

    attributes :id, :date, :user_id, :photo_url, :medication_was_taken, :symptoms, :taken_at, :updated_at, :doing_okay
    attribute :nausea_rating,  if: -> {!object.symptom_report.nausea_rating.nil?}

    def photo_url
        object.get_photo
    end

    def symptoms
        object.symptom_report.reported_symptoms
    end

    def medication_was_taken
        object.medication_report.medication_was_taken
    end

    def taken_at
        object.medication_report.datetime_taken
    end

    def nausea_rating
        object.symptom_report.nausea_rating
    end


end