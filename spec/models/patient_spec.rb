# spec/models/auction_spec.rb
require "rails_helper"

RSpec.describe Patient, :type => :model do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
    #@patient = FactoryBot.create(:patient, organization: @organization )
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
        patient.create_seed_report(Date.today,true)
        expect(patient.adherence).to eq((2.0 / 3).round(2))
      end
    end

  end

  describe ".has_temp_password" do
    let(:patient) { FactoryBot.create(:patient, treatment_start: DateTime.now()) }

    it("inital password reset state is false") do
      expect(patient.has_temp_password).to be false
    end

    it("after password reset, temp password state is true ") do
      patient.reset_password
      expect(patient.has_temp_password).to be true
    end

    it("after changing password again, the reset state should be false") do
      patient.update_password("new_password")
      expect(patient.has_temp_password).to be false
    end

  end

  # it "start of treatment is day 1" do
  #   patient = create_fresh_patient
  #   expect(patient.days_in_treatment).to eq(1)
  # end

  # it "7 days of treatment is 8th treatment day" do
  #   patient = create_fresh_patient()
  # end

  # it "newly created patient has accurate adherence + days in treatment" do
  #   patient = FactoryBot.create(:patient, treatment_start: Date.today, organization: @organization)
  #   expect(patient.adherence).to eq(0)

  #   patient.create_seed_report(Date.today, true)
  #   expect(patient.adherence).to eq(1)
  # end

  # it "adherence adapts to changing records" do
  #   patient = FactoryBot.create(:patient, treatment_start: Date.today - 1.week, organization: @organization)
  #   expect(patient.days_in_treatment).to eq(8)
  #   expect(patient.adherence).to eq(0)

  #   patient.seed_test_reports(true)
  #   patient.daily_reports.last.destroy
  #   expect(patient.adherence).to eq(1)

  #   patient.create_seed_report(Date.today, true)
  #   expect(patient.days_in_treatment).to eq(8)
  #   expect(patient.adherence).to eq(1)

  #   patient.daily_reports.first.destroy
  #   expect(patient.adherence).to eq(7 / 8)
  # end

  # it "cannot create more than one daily report per day" do
  #   patient = create_fresh_patient
  #   patient.create_seed_report(Date.today, true)
  #   patient.create_seed_report(Date.today, true)
  #   expect(patient.daily_reports.count).to eq(1)
  # end

  # it "adherence should only recalculate after a full day has passed" do
  #   patient = create_fresh_patient
  #   patient.create_seed_report(Date.today, true)

  #   travel_to( (Time.current + 2.day).change(hour: 12)) do
  #     expect(patient.adherence).to eq(1.0/2)
  #   end
  # end

  # it "adherence should reflect only days where medication was taken" do
  #   patient = create_fresh_patient
  #   patient.create_bad_report(Date.today)
  #   expect(patient.adherence).to eq(0)
  # end

  # it "weekly adhrence with medication missed" do
  #   patient = FactoryBot.create(:patient, treatment_start: Date.today - 1.week, organization: @organization)
  #   print(patient.treatment_start)
  #   patient.seed_test_reports(true)
  #   patient.daily_reports.last.destroy
  #   patient.create_bad_report(Date.today)
  #   expect(patient.adherence).to be == (6.0/7.0)
  # end

end
