require 'sidekiq-scheduler'

class ReminderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0
  
    def perform()
        Time.now.in_time_zone('America/Argentina/Buenos_Aires').to_date
        puts("Reminder worker running - this is supposed to happen at noon argentina time")
        notifications = Reminder.where("(datetime at time zone 'ART')::date = ? ", Time.now.in_time_zone('America/Argentina/Buenos_Aires').to_date + 1.day)
        if(notifications.length > 0)
            notifications.each do |notification|
                user = notification.patient

                body = "#{I18n.t("appointment.you_have")} #{I18n.t("appointment.#{notification.category}")} #{I18n.t('appointment.tomorrow')} "


                I18n.with_locale(user.locale) do
                    user.send_push_to_user(I18n.t('appointment.reminder'), body, "/", "appointment_reminder")
                end
                
                puts("Sent reminder to #{user.given_name} at #{Time.now.strftime("%H:%M")} with #{user.locale} locale")
            end
        else
            puts("No reminders found to send")
        end
        
    end
  end