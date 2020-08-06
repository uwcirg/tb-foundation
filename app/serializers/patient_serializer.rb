class PatientSerializer < ActiveModel::Serializer
    
    attributes :given_name, 
    :family_name, 
    :id, 
    :full_name, 
    :adherence, 
    :percentage_complete, 
    :days_in_treatment, 
    :last_report, 
    :treatment_start, 
    :current_streak, 
    :phone_number,
    :status,
    :daily_notification_time,
    :channel_id,
    :last_contacted,
    :photo_schedule,
    :weeks_in_treatment,
    :education_status,
    :age,
    :gender

    attribute :daily_reports,  if: -> {@instance_options[:all_details].present? || @instance_options[:include_daily_reports].present? }
    attribute :feeling_healthy_days,  if: -> {@instance_options[:all_details].present?}
    attribute :symptom_summary, if: -> { @instance_options[:include_symptom_summary].present?}
    attribute :number_missing_reports, if: -> { @instance_options[:include_missing_reports].present?}
    attribute :reporting_status, if: -> { @instance_options[:include_reporting_status].present?}
    attribute :last_symptoms, if: -> {@instance_options[:include_last_symptoms].present?}
    attribute :last_missed_day, if: -> {@instance_options[:include_last_missed_day].present?}
    attribute :support_requests, if: -> {@instance_options[:include_support_requests].present?}

    def full_name
        return("#{object.given_name} #{object.family_name}")
    end

    def symptom_summary
        object.daily_reports
    end

    def daily_notification_time
        if(object.daily_notification)
            return object.daily_notification.formatted_time
        end
    end

    def channel_id
        object.channels.where(is_private: true).first.id
    end

    def last_contacted
        object.channels.where(is_private: true).first.last_message_time
    end

    def education_status
        object.education_message_statuses.pluck(:treatment_week)
    end


end