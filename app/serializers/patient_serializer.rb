class PatientSerializer < BasePatientSerializer
    
    attributes :given_name, 
    :family_name, 
    :id, 
    :full_name, 
    :adherence,
    :photo_adherence,
    :percentage_complete, 
    :days_in_treatment, 
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
    :gender,
    :last_education_status,
    :has_forced_password_change,
    :treatment_end_date,
    :photo_summary,
    :last_photo_request_status

    attribute :daily_reports,  if: -> {@instance_options[:all_details].present? || @instance_options[:include_daily_reports].present? }
    attribute :feeling_healthy_days,  if: -> {@instance_options[:all_details].present?}
    attribute :number_missing_reports, if: -> { @instance_options[:include_missing_reports].present?}
    attribute :reporting_status, if: -> { @instance_options[:include_reporting_status].present?}
    attribute :last_symptoms, if: -> {@instance_options[:include_last_symptoms].present?}
    attribute :last_missed_day, if: -> {@instance_options[:include_last_missed_day].present?}
    attribute :support_requests, if: -> {@instance_options[:include_support_requests].present?}
    
    has_many :daily_reports do
        @object.daily_reports.where(date: [Date.today, Date.today-1]).order("date DESC")
      end

    has_one :last_report do
        @object.daily_reports.last
    end

    has_one :last_contact_tracing_survey do
        @object.contact_tracing_surveys.last
    end

    def full_name
        return("#{object.given_name} #{object.family_name}")
    end

    def daily_notification_time
        if(object.daily_notification)
            return object.daily_notification.formatted_time
        end
    end

    def channel_id
        object.channels.where(is_private: true).first.id
    end

    def education_status
        object.education_message_statuses.pluck(:treatment_day)
    end
    
    def last_education_status
        day = object.education_message_statuses.order("treatment_day DESC").first
        if(day.nil?) 
            return 0
        end
        
        return day.treatment_day
    end
    
    
    #Stuff that was used for practitioner response but not needed for patient side
    
    def last_contacted
        object.channels.where(is_private: true).first.last_message_time
    end
    
    def photo_adherence
        object.patient_information.photo_adherence
    end
    
    def photo_summary
        object.patient_information.photo_reporting_summary
    end
    
    def gender
        object.gender == "Other" ? object.gender_other || "Other" : object.gender
    end
    
end