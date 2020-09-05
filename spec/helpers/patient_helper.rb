module PatientHelper

    def create_fresh_patient(date = Date.today)
        FactoryBot.create(:patient, treatment_start: date, organization: @organization)
    end

    def generate_perfect_history(patient)
        (patient.treatment_start.to_date..DateTime.current.to_date).each do |day|
            patient.create_perfect_report(day)
        end
    end

    def create_patient_given_reporting_history(good,total)
        i = 0
        patient = FactoryBot.create(:patient, treatment_start: Date.current - total.days)
        (patient.treatment_start.to_date..Date.current).each do |day|
            if( i < good)
                patient.create_perfect_report(day)
            end
            i+=1
        end
        patient
    end

    def create_severe_symptom_report(patient)
        patient.daily_reports.create!(
            date: Date.current,
            medication_report: patient.medication_reports.create!(medication_was_taken: false, datetime_taken: DateTime.current),
            symptom_report: patient.symptom_reports.create!(nausea: true,nausea_rating: 9)
        )
    end
  end