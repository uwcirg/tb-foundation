#Serializer used for practitioner viewing a patients information
class PractitionerPatientSerializer < BasePatientSerializer
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
             :weeks_in_treatment,
             :age,
             :gender,
             :treatment_end_date,
             :photo_summary,
             :last_symptoms,
             :support_requests,
             :last_missed_day,
             :reporting_status,
             :priority,
             :medication_summary,
             :photo_schedule

  has_one :last_report do
    @object.daily_reports.last
  end

  has_one :next_reminder do
    @object.next_reminder
  end

  def daily_notification_time
    if (object.daily_notification)
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

  def photo_summary
    object.patient_information.photo_reporting_summary
  end

  def medication_summary
    {
      adherent_days: object.patient_information.adherent_days,
      reported_missed_days: object.patient_information.days_reported_not_taking_medication,
      days_since_app_start: object.patient_information.medication_adherence_denominator,
    }
  end

  def priority
    object.patient_information.priority
  end
end
