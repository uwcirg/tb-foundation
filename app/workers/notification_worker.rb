require 'sidekiq-scheduler'

class NotificationWorker
    include Sidekiq::Worker
  
    def perform()
        user = Patient.where(given_name: "Julio").first
        #user.send_push_to_user("Medication Reminder!!!","Take your medication!")
        puts(Time.now)
    end
  end