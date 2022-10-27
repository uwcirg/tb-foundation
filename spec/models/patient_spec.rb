require "rails_helper"

RSpec.describe Patient, :type => :model do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".has_temp_password" do
    let(:patient) { FactoryBot.create(:patient, treatment_start: DateTime.now()) }

    it("is initally set to false") do
      expect(patient.has_temp_password).to be false
    end

    it("is true after password resest completed") do
      patient.reset_password
      expect(patient.has_temp_password).to be true
    end

    it("it is false when password has been manually updated") do
      patient.update_password("new_password")
      expect(patient.has_temp_password).to be false
    end
  end

  # Should probably move this to -> daily_report_spec.rb
  # describe "daily_report creation" do
  #   it "cannot create more than one daily report per day, but will record individual report parts" do
  #     patient = create_fresh_patient
  #     report_1 = patient.create_seed_report(patient.localized_date, true)
  #     report_2 = patient.create_seed_report(patient.localized_date, false)
  #     expect(patient.daily_reports.count).to eq(1)
  #     expect(patient.medication_reports.count).to eq(2)
  #   end
  # end

  describe ".messaging_notifications" do
    let(:patient) { create_fresh_patient }
    it "creates one unread messagee for asistant and one for site" do
      expect(patient.messaging_notifications.count).to eq(2)
    end

    it "creates unread messages for existing public channels" do
      @practitioner.channels.create!(title: "Test", subtitle: "Test")
      expect(patient.messaging_notifications.count).to eq(3)
    end

    it "creates unread messages when a new channel is created" do
      expect(patient.messaging_notifications.count).to eq(2)
      @practitioner.channels.create!(title: "Test", subtitle: "Test", is_private: false).messages.create!(body: "Test", user_id: @practitioner.id)
      expect(patient.messaging_notifications.count).to eq(3)
    end
  end

  describe ".treatment_end_date" do
    let(:patient) { create_fresh_patient }
    it "has a treatment default end date of + 6 months " do
      expect(patient.treatment_end_date).to eq((DateTime.now + 180.days).to_date)
    end
  end

  describe ".has_forced_password_change" do
    let(:patient) { create_fresh_patient }
    it "initally does not have password reset request" do
      expect(patient.has_forced_password_change).to eq(false)
    end

    it "changes state after password reset" do
      patient.reset_password
      expect(patient.has_forced_password_change).to eq(true)
    end

    it "is not true when patient is pending" do
      patient.update!(status: "Pending")
      expect(patient.has_forced_password_change).to eq(false)
    end
  end

  describe(".requested_test_not_submitted") do
    let(:patient) { create_fresh_patient }
    it("returns a patient who has not yet submitted thier photo") do
      patient.add_photo_day
      expect(Patient.requested_test_not_submitted(patient.localized_date)[0]).to eq(patient)
    end

    it("does not return a patient who has submitted thier photo") do
      patient.add_photo_day
      patient.photo_reports.create!(photo_url: "test", date: Date.today)
      expect(Patient.requested_test_not_submitted(Date.today).count).to eq(0)
    end

    it("does not return a patient who has submitted a reason for skipping") do
      patient.add_photo_day
      patient.photo_reports.create!(photo_was_skipped: true, date: Date.today, why_photo_was_skipped: "Test")
      expect(Patient.requested_test_not_submitted(Date.today).count).to eq(0)
    end
  end

  describe ".adherence" do
    it("is zero when initalized ") do
      patient = FactoryBot.create(:patient, treatment_start: Time.now)
      patient.activate
      expect(patient.adherence).to eq(0)
    end

    it("after 1st report is 1") do
      patient = FactoryBot.create(:patient, treatment_start: Time.now)
      patient.activate
      patient.create_seed_report(patient.localized_date, true)
      patient.reload
      expect(patient.adherence).to eq(1)
    end

    it("reflects reporting on 4th day for the first time") do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.activate(Time.now - 3.days)
      patient.create_seed_report(patient.localized_date, true)
      patient.reload
      expect(patient.adherence).to eq(1.0 / 4.0)
    end

    it("timezone edge case") do
      #Testing timezone edge cases regression test for failing tests after 9pm EST
      travel_to((Time.current + 1.day).change(hour: 1, min: 34)) do
        patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
        patient.activate(Time.now - 3.days)
        patient.create_seed_report(patient.localized_date, true)
        patient.reload
        expect(patient.adherence).to eq(1.0 / 4.0)
      end
    end

    it("reflects 4th day not yet reported, 3 previous days reported") do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.activate(Time.now - 3.days)
      patient.create_seed_report(patient.localized_date - 3.days, true)
      patient.create_seed_report(patient.localized_date - 2.days, true)
      patient.create_seed_report(patient.localized_date - 1.days, true)
      patient.reload
      expect(patient.adherence).to eq(1)
    end

    it("reflects reporting for first 3 days and 4th day") do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.activate(Time.now - 3.days)
      patient.create_seed_report(patient.localized_date - 3.days, true)
      patient.create_seed_report(patient.localized_date - 2.days, true)
      patient.create_seed_report(patient.localized_date - 1.days, true)
      patient.create_seed_report(patient.localized_date, true)
      patient.reload
      expect(patient.adherence).to eq(1)
    end

    it "should reflect only days where medication was taken" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.activate(Time.now - 3.days)
      patient.create_seed_report(patient.localized_date - 3.days, true)
      patient.create_seed_report(patient.localized_date - 2.days, true)
      patient.create_seed_report(patient.localized_date - 1.days, true)
      patient.create_bad_report(patient.localized_date)
      patient.reload
      expect(patient.adherence).to eq(3.0 / 4.0)
    end

    it "should only reflect medication reports attached to a daily_report" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.activate(Time.now - 3.days)
      patient.create_seed_report(patient.localized_date - 3.days, true)
      patient.medication_reports.create!(date: Date.today, medication_was_taken: true)
      patient.medication_reports.create!(date: Date.today - 1.day, medication_was_taken: true)
      patient.reload
      expect(patient.adherence).to eq(0.33)
    end
  end

  describe "scope: unresponsive" do

    it "should not include a newly created patient" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now)
      expect(Patient.unresponsive.count).to eq(0)
    end

    it "should not include a patient that started yesterday" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 1.days)
      expect(Patient.unresponsive.count).to eq(0)
    end

    it "should include a patient that has not reported in 3 days" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      expect(Patient.unresponsive.count).to eq(1)
    end

    it "should not show a patient that reported today" do
      patient = FactoryBot.create(:patient, treatment_start: Time.now - 3.days)
      patient.create_seed_report(patient.localized_date,true)
      expect(Patient.unresponsive.count).to eq(0)
    end

  end
end
