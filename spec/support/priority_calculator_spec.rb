# spec/models/auction_spec.rb
require "rails_helper"

RSpec.describe PriorityCalculator do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".priority" do
    let(:patient) { FactoryBot.create(:patient, treatment_start: DateTime.now() - 1.week) }

    it("perfect patient is low priority") do
      generate_perfect_history(patient)
      expect(PriorityCalculator.new(patient).priority).to eq(0)
    end

    it("patient with adherence = 0 is high priority") do
      expect(PriorityCalculator.new(patient).priority).to eq(2)
    end

    it("patient with adhrence = 92 is medium priority") do
      patient = create_patient_given_reporting_history(23, 25)
      expect(PriorityCalculator.new(patient).priority).to eq(1)
    end

    it("patient wiht adhrence = 92 and severe symptom is high priority") do
        patient = create_patient_given_reporting_history(24, 25)
        create_severe_symptom_report(patient)
        expect(PriorityCalculator.new(patient).priority).to eq(2)

    end
  end
end
