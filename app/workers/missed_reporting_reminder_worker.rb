class MissedReportingReminderWorker
    include Sidekiq::Worker

    def perform()
        PatientReminderHelper.new.send_missed_reporting_reminders
    end
    
  end