require 'sidekiq-scheduler'

class NotificationWorker
    include Sidekiq::Worker
  
    def perform()
        #Time.now.str
        puts(DailyNotification.all().as_json)
        puts(" time = '#{Time.now.utc.strftime("%H:%M")}'")
        notifications = DailyNotification.where("time = '#{Time.now.utc.strftime("%H:%M")}'")
        if(notifications.length > 0)

            notifications.each do |notification|
                user = notification.user
                puts(user.given_name)
                user.send_push_to_user("Medication Reminder!", "Sent from server at #{Time.now.strftime("%H:%M")} to #{user.given_name} ", "/home/report/0")
                puts("Sent notification to #{user.given_name} at #{Time.now.strftime("%H:%M")}")
            end
        else
            puts("No notifications to send found")
        end
        
    end
  end