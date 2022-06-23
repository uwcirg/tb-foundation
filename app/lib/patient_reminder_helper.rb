class PatientReminderHelper
  def send_test_reminders(reminder_number)
    patients_to_notify = Patient.requested_test_not_submitted(ApplicationTime.todays_date)

    patients_to_notify.each do |patient|
      notifier = NotifyPatient.new(patient)
      reminder_number == 2 ? notifier.photo_day_reminder_one : notifier.photo_day_reminder_two
    end
  end

  def send_missed_reporting_reminders
    patients_to_notify = Patient.unresponsive
    patients_to_notify.each do |patient|
      evaluate_history_and_send_reminder(patient)
    end
  end

  private

  def evaluate_history_and_send_reminder(patient)
    notifier = NotifyPatient.new(patient)

    days_since = days_since_patients_last_report(patient)
    n_reminders_sent = patient.patient_information.reminders_since_last_report

    if (days_since >= 30 and n_reminders_sent < 3)
      notifier.missed_thirty_days_reminder
    end

    if (days_since >= 7 and n_reminders_sent < 2)
      notifier.missed_seven_days_reminder
    end

    if (days_since >= 3 and n_reminders_sent < 1)
      notifier.missed_three_days_reminder
    end

  end

  def days_since_patients_last_report(patient)
    last_report = patient.daily_reports.order("created_at").last
    datetime_last_report = patient.patient_information.datetime_patient_activated || patient.treatment_start

    if (not last_report.nil?)
      datetime_last_report = last_report.created_at
    end
    days_since_last_report = (ApplicationTime.todays_date - datetime_last_report.to_date).to_i
  end
end
