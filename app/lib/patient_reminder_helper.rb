class PatientReminderHelper
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

  def send_missed_day_reminder
    
    # TODO 
    # Create patient_information table missed_day_notif_count:integer
    # add has_one relationship on patient model


    #increment number of missed_day_notifications in PatientProfile table 
    #Check Number -> send corresponding message 
    #If == 3 return
    #else
    #Send message and increment number of messages sent

    #Spec from Fernando
    # Hello, it has been 3 days since your last report of the medication. Please remember to contact your treatment assistant if you are having any problems  or any difficulty with the app.
    # Hola, han pasado 3 dias desde el ultimo reporte de medicacion. Por favor recuerde contactar a su asistente de tratamiento si tiene algun problema o alguna dificultad con la aplicacion. Gracias

    # 7 days without notification - Hello, we have no records of your reports for the last week days. Please contact your treatment assistant who will help you resolve any difficulty.
    #  Hola, No hemos recibido su reporte de medicacion en la ultima semana. Por favor contacte a su asistente de tratamiento en cuanto pueda para resolver cualquier dificultad. Gracias

    # 30 days without notification - Hello, Please remember that it is very important to keep taking the medication to cure TB . We need to know that you are OK. Please contact your assistant or your doctor as soon as possible.
    # Hola, por favor recuerde que es muy importante seguir tomando la medicacion para curar la TB. Necesitamos saber que Ud. esta bien. Por favor contacte a su asistente o a su medico a la brevedad posible.  Gracias

  end
end
