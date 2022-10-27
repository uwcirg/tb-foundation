require "rails_helper"

RSpec.describe PatientReminderHelper, type: :model do
  before(:all) do
    create_first_organization
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".send_test_reminders" do
    it "sends push notifications to a patient that has not yet submitted" do
      PhotoDay.all.destroy_all
      @patients[0].add_photo_day(ApplicationTime.todays_date)
      PatientReminderHelper.new.send_test_reminders(1)
      expect(@patients[0].push_notification_statuses.where(notification_type: "TestStripReminder").count).to eq(1)
    end
  end

end
