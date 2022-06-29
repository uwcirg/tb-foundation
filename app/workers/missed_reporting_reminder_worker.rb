class MissedReportingReminderWorker
    include Sidekiq::Worker

    def perform()
        puts("Ran missing reporting reminders worker")
        PatientReminderHelper.new.send_missed_reporting_reminders
    end
    
  end