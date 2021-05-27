#Serializer used for practitioner viewing a patients information
class PractitionerPatientSerializer < ActiveModel::Serializer
    
    attributes :given_name, 
    :family_name, 
    :id, 
    :full_name, 
    :adherence,
    :photo_adherence,
    :percentage_complete, 
    :days_in_treatment, 
    :treatment_start, 
    :phone_number,
    :status,
    :channel_id,
    :last_contacted,
    :photo_schedule,
    :weeks_in_treatment,
    :age,
    :gender,
    :has_forced_password_change,
    :treatment_end_date,
    :photo_summary,
    :last_symptoms,
    :support_requests,
    :last_missed_day,
    :reporting_status

    # has_many :daily_reports do
    #     @object.daily_reports.where(date: [Date.today, Date.today-1]).order("date DESC")
    #   end

    # has_one :last_report do
    #     @object.daily_reports.last
    # end

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

    def gender
        object.gender == "Other" ? object.gender_other || "Other" : object.gender
    end

    def photo_adherence
        object.patient_information.photo_adherence
    end

    def photo_summary
        object.patient_information.photo_reporting_summary
    end

end