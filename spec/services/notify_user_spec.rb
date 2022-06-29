require "rails_helper"

RSpec.describe NotifyUser, type: :model do
  before(:all) do
    create_first_organization
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it ".medication_reminder sends a medication reminder" do
    @patients[0].update!(locale: "en")
    expect(PushNotificationSender).to receive(:send).with(@patients[0],
                                                          "Medication Reminder", "Have you taken your medication today, and are you feeling okay?",
                                                          "/home",
                                                          "MedicationReminder",
                                                          [{ :action => "good", :title => "👍 Yes" }, { :action => "issue", :title => "💬 No" }])

    NotifyUser.new(@patients[0]).medication_reminder
  end

  it ".medication_reminder adjusts translations for locale" do
    @patients[0].update!(locale: "es-AR")
    expect(PushNotificationSender).to receive(:send).with(@patients[0], "Recuerde de reportar cada dia", any_args)
    NotifyUser.new(@patients[0]).medication_reminder
  end

  it ".missed_three_days_reminder sends a reminder for 3 day" do
    @patients[0].update!(locale: "en")
    expect(PushNotificationSender).to receive(:send).with(@patients[0], "No report for the past 3 days", any_args)
    NotifyUser.new(@patients[0]).missed_three_days_reminder
  end

  it ".missed_seven_days_reminder sends a reminder for 7 day" do
    @patients[0].update!(locale: "en")
    expect(PushNotificationSender).to receive(:send).with(@patients[0], "No report for the past 7 days", any_args)
    NotifyUser.new(@patients[0]).missed_seven_days_reminder
  end

  it ".missed_thirty_days_reminder sends a reminder for 30 day" do
    @patients[0].update!(locale: "en")
    expect(PushNotificationSender).to receive(:send).with(@patients[0], "No report for the past month", any_args)
    NotifyUser.new(@patients[0]).missed_thirty_days_reminder
  end



end
