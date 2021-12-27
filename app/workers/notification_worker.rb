require 'sidekiq-scheduler'

class NotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0
  
    def perform()
        notifications = DailyNotification.where("time = '#{Time.now.utc.strftime("%H:%M")}'")
        if(notifications.length > 0)
            notifications.each do |notification|
                user = notification.user
                # I18n.with_locale(user.locale) do
                #     user.send_push_to_user(I18n.t('medication_reminder'), I18n.t('medication_reminder_body'), "/", "MedicationReminder")
                # end
                user.send_medication_reminder
                puts("Sent notification to #{user.id} at #{Time.now.strftime("%H:%M")} with #{user.locale} locale")
            end
        else
            puts("No notifications to send found")
        end
        
    end
  end