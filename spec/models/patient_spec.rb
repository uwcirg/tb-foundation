require "rails_helper"

RSpec.describe Patient, :type => :model do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".adherence" do
    let(:patient) { FactoryBot.create(:patient, treatment_start: DateTime.now()) }

    it("inital adherence is zero") do
      expect(patient.adherence).to eq(0)
    end

    it("adherence with one report is 1") do
      patient.create_seed_report(Date.today, true)
      expect(patient.adherence).to eq(1)
    end

    it("adherence on 3rd day with 1 report before reporting") do
      patient.create_seed_report(Date.today, true)
      travel_to((Time.current + 2.day).change(hour: 12)) do
        expect(patient.adherence).to eq(1.0 / 2)
        patient.create_bad_report(Date.today)
        expect(patient.adherence).to eq((1.0 / 3).round(2))
      end
    end

    it("adherence on 3rd day with good report") do
      patient.create_seed_report(Date.today, true)
      travel_to((Time.current + 2.day).change(hour: 12)) do
        expect(patient.adherence).to eq(1.0 / 2)
        patient.create_seed_report(Date.today, true)
        expect(patient.adherence).to eq((2.0 / 3).round(2))
      end
    end

    it "adherence adapts to changing records" do
      patient = FactoryBot.create(:patient, treatment_start: Date.today - 1.week, organization: @organization)
      expect(patient.days_in_treatment).to eq(8)
      expect(patient.adherence).to eq(0)

      patient.seed_test_reports(true)
      patient.daily_reports.last.destroy
      expect(patient.adherence).to eq(1)

      patient.create_seed_report(Date.today, true)
      expect(patient.days_in_treatment).to eq(8)
      expect(patient.adherence).to eq(1)

      patient.daily_reports.first.destroy
      expect(patient.adherence).to eq((7.0 / 8.0).round(2))
    end

    it "adherence should only recalculate after a full day has passed" do
      patient = create_fresh_patient
      patient.create_seed_report(Date.today, true)

      travel_to((Time.current + 2.day).change(hour: 12)) do
        expect(patient.adherence).to eq(1.0 / 2)
      end
    end

    it "adherence should reflect only days where medication was taken" do
      patient = create_fresh_patient
      patient.create_bad_report(Date.today)
      expect(patient.adherence).to eq(0)
    end
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
  #     report_1 = patient.create_seed_report(Date.today, true)
  #     report_2 = patient.create_seed_report(Date.today, false)
  #     expect(patient.daily_reports.count).to eq(1)
  #     expect(patient.medication_reports.count).to eq(2)
  #   end
  # end

  describe ".messaging_notifications" do
    let(:patient) { create_fresh_patient }
    it "creates one unread messagee for  " do
      expect(patient.messaging_notifications.count).to eq(1)
    end

    it "creates unread messages for existing public channels" do
      @practitioner.channels.create!(title: "Test", subtitle: "Test")
      expect(patient.messaging_notifications.count).to eq(2)
    end

    it "creates unread messages when a new channel is created" do
      expect(patient.messaging_notifications.count).to eq(1)
      @practitioner.channels.create!(title: "Test", subtitle: "Test", is_private: false).messages.create!(body: "Test", user_id: @practitioner.id)
      expect(patient.messaging_notifications.count).to eq(2)
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
end
