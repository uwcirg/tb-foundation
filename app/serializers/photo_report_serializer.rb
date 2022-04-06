class PhotoReportSerializer < ActiveModel::Serializer
    
    attributes :photo_id, :approved, :url, :patient_id, :date, 
    :created_at, :site, :photo_was_skipped, :why_photo_was_skipped, 
    :back_submission, :redo_flag, :redo_reason, :redo_original_details, :is_redo, :auto_detected_barcode

    attribute :is_first_report_for_patient, if: -> { !@instance_options[:first_report_ids].nil? }

    def url
        object.get_url
    end

    def is_redo
        not object.redo_original_report.nil?
    end

    def redo_original_details
        object.redo_original_report ? {
            url: object.redo_original_report.get_url,
            reason: object.redo_original_report.redo_reason
            } : nil
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

    def is_first_report_for_patient
        @instance_options[:first_report_ids].include?(object.id)
    end

end