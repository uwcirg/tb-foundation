require "rails_helper"

RSpec.describe SymptomReport, :type => :model do

  describe "self.locale_symptoms" do

    it("should return symptoms for argentina by default") do
      expect(patient.has_temp_password).to be false
    end

  end
end
