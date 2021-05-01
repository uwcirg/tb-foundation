require 'sidekiq-scheduler'

class PhotoReminderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0
  
    def perform(args = 1)

        title = (args == 2) ? "Último recordatorio: complete su tira reactiva hoy" : "Por favor complete su tira reactiva hoy"
        body = (args == 2) ? "Son más de las 19 horas y aún no ha completado su tira reactiva. Complete su tira para mantenerse al día con el tratamiento" : "Hoy le toca enviar su tira reactiva. Por favor complételo antes de la medianoche."
        
        todays_date = Time.now.in_time_zone('America/Argentina/Buenos_Aires').to_date
        patients_to_notify = Patient.joins(:photo_days).where(photo_days: {date: todays_date})

        patients_to_notify.each do |patient|
            patient.send_push_to_user(title, body, "/","test_strip_reminder")
        end

    end
  end