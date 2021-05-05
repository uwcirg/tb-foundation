require "sidekiq-scheduler"

class PhotoReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(args = 1)
    PatientReminderHelper.new.send_test_reminders(args)
  end
end
