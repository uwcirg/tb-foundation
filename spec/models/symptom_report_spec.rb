require "rails_helper"

RSpec.describe SymptomReport, :type => :model do
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".has_symptom" do
    it "returns reports with symptoms" do
      one = FactoryBot.create(:symptom_report, nausea: true)
      two = FactoryBot.create(:symptom_report, redness: true)
      expect(SymptomReport.has_symptom).to eq [one, two]
    end

    it "returns reports with vertigo when using indonesian locale" do
      one = FactoryBot.create(:symptom_report, vertigo: true)
      expect(SymptomReport.has_symptom("id")).to eq [one]
    end

    it "does not return reports with vertigo when using argentina locale" do
      one = FactoryBot.create(:symptom_report, vertigo: true)
      expect(SymptomReport.has_symptom("es-Ar")).to eq []
    end
  end

  describe ".has_severe_symptom" do
    it "returns reports with redness when using indonesian locale" do
      one = FactoryBot.create(:symptom_report, redness: true)
      expect(SymptomReport.has_severe_symptom("id")).to eq [one]
    end

    it "does not return reports with redness when using argentina locale" do
      one = FactoryBot.create(:symptom_report, redness: true)
      expect(SymptomReport.has_severe_symptom("es-Ar")).to eq []
    end
  end
end
