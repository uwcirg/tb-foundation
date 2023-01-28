class PatientReminderHelper
  def send_test_reminders(reminder_number)
    patients_to_notify = Patient.requested_test_not_submitted(ApplicationTime.todays_date)
    patients_to_notify.each do |patient|
      notifier = NotifyUser.new(patient)
      reminder_number == 2 ? notifier.photo_reminder_two : notifier.photo_reminder_one
    end
  end


  # need to send patient a message from practitioner regarding the test strip asks.


  def send_post_treatment_test_prompt
    patients_to_notify = Patient.where(treatment_end_date: Time.now - 3.day..Time.now)
    patients_to_notify.each do |patient|
      notifier = NotifyUser.new(patient)
      notifier.post_treatment_teststrip_prompt
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
    notifier = NotifyUser.new(patient)

    days_since = days_since_patients_last_report(patient)
    n_reminders_sent = patient.patient_information.reminders_since_last_report

    if (days_since >= 30 and n_reminders_sent < 3)
      notifier.missed_thirty_days_reminder
      patient.patient_information.update!(reminders_since_last_report: 3)
    elsif(days_since >= 7 and n_reminders_sent < 2)
      notifier.missed_seven_days_reminder
      patient.patient_information.update!(reminders_since_last_report: 2)
    elsif(days_since >= 3 and n_reminders_sent < 1)
      notifier.missed_three_days_reminder
      patient.patient_information.update!(reminders_since_last_report: 1)
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
