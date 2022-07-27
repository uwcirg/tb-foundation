require "rails_helper"

RSpec.describe SymptomReport, :type => :model do
  before(:all) do
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".has_symptom" do
    it "returns reports with symptoms" do
      one = FactoryBot.create(:symptom_report, nausea: true)
      two = FactoryBot.create(:symptom_report, redness: true)
      expect(SymptomReport.has_symptom).to eq [one,two]
    end
  end
end
