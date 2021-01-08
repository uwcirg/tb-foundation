require "rest-client"

class PatientTransfer

    def transfer_patient(args)
        response = RestClient.post("#{args[:url]}/auth", { email: args[:email], password: args[:password] })
        good_cookie = response.cookies
    
        reports = RestClient.get("#{args[:url]}/patient/#{args[:demo_patient_id]}/json_reports", { :cookies => good_cookie })
        other_info = JSON.parse(RestClient.get("#{args[:url]}/practitioner/patient/#{args[:demo_patient_id]}", { :cookies => good_cookie }))

        parsed = JSON.parse(reports)
    
        ActiveRecord::Base.transaction do
          patient = Patient.find(args[:live_patient_id])
    
          parsed.each do |report|
            if (!report["photo_report"].nil?)
              photo_report = report["photo_report"]
              photo_report["practitioner_id"] = patient.organization.practitioners.first.id;
              photo_report["user_id"] = patient.id
              photo_report.delete("id")
              new_p = patient.photo_reports.create!(photo_report)
              patient.photo_days.create!(date: report["date"])
              report["photo_report"] = new_p
            end
    
            medication_report = report["medication_report"]
            medication_report["user_id"] = patient.id
            medication_report.delete("id")
    
            symptom_report = report["symptom_report"]
            symptom_report["user_id"] = patient.id
            symptom_report.delete("id")
    
            new_m = patient.medication_reports.create!(medication_report)
            new_s = patient.symptom_reports.create!(symptom_report)
    
            report["medication_report"] = new_m
            report["symptom_report"] = new_s
            report["user_id"] = patient.id
            report.delete(:id)
    
            # if(patient.daily_reports.find_by(report["date"]))
    
            if (patient.daily_reports.where(date: report["date"]).exists?)
              patient.daily_reports.find_by(date: report["date"]).update!(report)
            else
              patient.daily_reports.create!(report)
            end

              patient.update!(treatment_start: other_info["treatmentStart"])
          end
        end
    end

end
