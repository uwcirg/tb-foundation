class PatientReminderHelper

    def send_test_reminders(reminder_number)
        
        #TODO - add i18n refs instead of hardcoded
        title = (reminder_number == 2) ? "Recordatorio: Hoy se requiere la tira reactiva." : "Tira reactiva requerido hoy"
        body = (reminder_number == 2) ? "Queremos asegurarnos que estés bien. Nos comunicaremos contigo se no recibimos la foto al fin del día." : "Complete y envíe la foto lo antes posible para que sepamos que está bien encaminado."
        
        #TODO - could check which patients have been notifed via PushNotificationStatus table to make more idempotent
        todays_date = Time.now.in_time_zone('America/Argentina/Buenos_Aires').to_date
        patients_to_notify = Patient.requested_test_not_submitted(todays_date)
        
        patients_to_notify.each do |patient|
            patient.send_push_to_user(title, body, "/","TestStripReminder")
        end
    end

end