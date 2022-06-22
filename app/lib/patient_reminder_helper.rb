class PatientReminderHelper
  # REPORTING_BODY_STRINGS = ["Hola, han pasado 3 dias desde el ultimo reporte de medicacion. Por favor recuerde contactar a su asistente de tratamiento si tiene algun problema o alguna dificultad con la aplicacion. Gracias",
  #                           "Hola, No hemos recibido su reporte de medicacion en la ultima semana. Por favor contacte a su asistente de tratamiento en cuanto pueda para resolver cualquier dificultad. Gracias",
  #                           "Hola, por favor recuerde que es muy importante seguir tomando la medicacion para curar la TB. Necesitamos saber que Ud. esta bien. Por favor contacte a su asistente o a su medico a la brevedad posible.  Gracias"]

  # REPORTING_SEGMENTS = ["3","7", "30"]

  def send_test_reminders(reminder_number)

    #TODO - add i18n refs instead of hardcoded
    title = (reminder_number == 2) ? "Recordatorio: Hoy se requiere la tira reactiva." : "Tira reactiva requerido hoy"
    body = (reminder_number == 2) ? "Queremos asegurarnos que estés bien. Nos comunicaremos contigo se no recibimos la foto al fin del día." : "Complete y envíe la foto lo antes posible para que sepamos que está bien encaminado."

    #TODO - could check which patients have been notifed via PushNotificationStatus table to make more idempotent
    todays_date = Time.now.in_time_zone("America/Argentina/Buenos_Aires").to_date
    patients_to_notify = Patient.requested_test_not_submitted(todays_date)

    patients_to_notify.each do |patient|
      patient.send_push_to_user(title, body, "/", "TestStripReminder")
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
