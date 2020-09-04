module PatientHelper

    def create_fresh_patient(date = Date.today)
        FactoryBot.create(:patient, treatment_start: date, organization: @organization)
    end
  end