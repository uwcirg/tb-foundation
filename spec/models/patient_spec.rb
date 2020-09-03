# spec/models/auction_spec.rb
require "rails_helper"

RSpec.describe Patient, :type => :model do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
    #@patient = FactoryBot.create(:standard_patient, organization: @organization )
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "newly created patient has accurate adherence + days in treatment" do
    patient = FactoryBot.create(:patient, treatment_start: Date.today, organization: @organization)
    expect(patient.days_in_treatment).to eq(1)
    expect(patient.adherence).to eq(0)

    patient.create_seed_report(Date.today, true)
    expect(patient.adherence).to eq(1)
  end

  it "adherence adapts to changing records" do
    patient = FactoryBot.create(:patient, treatment_start: Date.today - 1.week, organization: @organization)
    expect(patient.days_in_treatment).to eq(7)
    expect(patient.adherence).to eq(0)

    patient.seed_test_reports(true)
    patient.daily_reports.last.destroy
    expect(patient.adherence).to eq(1)

    patient.create_seed_report(Date.today, true)
    expect(patient.days_in_treatment).to eq(8)
    expect(patient.adherence).to eq(1)

    patient.daily_reports.first.destroy
    expect(patient.adherence).to eq(7 / 8)
  end

  it "cannot create more than one daily report per day" do
    patient = FactoryBot.create(:patient, treatment_start: Date.today, organization: @organization)
    patient.create_seed_report(Date.today, true)
    patient.create_seed_report(Date.today, true)
    expect(patient.daily_reports.count).to eq(1)

  end

  # it "patient had accurate adhernece when day has not been reported" do
  #   days = (Date.today - @patient.treatment_start.to_date).to_i
  #   @patient.seed_test_reports(true)
  #   @patient.daily_reports.last.destroy
  #   print("Treatment Start: #{@patient.treatment_start}")
  #   print("reports: #{@patient.daily_reports.count}  days: #{days}")
  #   expect(true).to eq(true)
  # end

  # it "patient has accurate adherence when day has been reported" do
  #   puts(@patient.treatment_start)
  #   @patient.seed_test_reports(true)
  #   #puts(@patient.daily_reports.order("date").first.date)
  #   days = (Date.today - @patient.treatment_start.to_date).to_i
  #   #puts(" patients length #{Patient.all.count}")
  #   print("reports: #{@patient.daily_reports.count}  days: #{days}")
  #   expect(@patient.daily_reports.count).to eq(days)
  # end

end
