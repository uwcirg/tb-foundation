class PatientReminderHelper

  def send_test_reminders(reminder_number)
    patients_to_notify = Patient.requested_test_not_submitted(ApplicationTime.todays_date)

    patients_to_notify.each do |patient|
      notifier = NotifyPatient.new(patient)
      reminder_number == 2 ? notifier.photo_day_reminder_one : notifier.photo_day_reminder_two
    end
  end

  def send_missed_reporting_reminders

    patients_to_notify = Patient.includes(:patient_information, :daily_reports).active.has_not_reported_in_more_than_three_days

    patients_to_notify.each do |patient|
      reminder_type = evaluate_history_and_send_reminder(patient)
      send_reporting_reminder(patient,reminder_type) unless reminder_type == 0
    end

  end

  private

  def send_reporting_reminder(patient,type)
    patient.send_push_to_user("No ha reportado en los últimos #{REPORTING_SEGMENTS[type-1]} días", REPORTING_BODY_STRINGS[type-1] , app_url = "/missing-reporting/#{type}", 5)
    patient.update_number_of_missed_reporting_reminders_sent(type)
  end

  def evaluate_history_and_send_reminder(patient)
    days_since = days_since_patients_last_report(patient)
    n_reminders_sent = patient.patient_information.reminders_since_last_report

    if (days_since >= 30 and n_reminders_sent < 3)
      return 3
    end

    if (days_since >= 7 and n_reminders_sent < 2)
      return 2
    end

    if (days_since >= 3 and n_reminders_sent < 1)
      return 1
    end

    return 0
  end

  def days_since_patients_last_report(patient)
    last_report = patient.daily_reports.order("created_at").last
    datetime_last_report = patient.patient_information.datetime_patient_activated || patient.treatment_start

    if (not last_report.nil?)
      datetime_last_report = last_report.created_at
    end
    days_since_last_report = (Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date - datetime_last_report.to_date).to_i

  end
end
