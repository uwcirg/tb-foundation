namespace :patient_information do
  desc "Add messaging channel per site for site level announcements - 5/7/21"
  task :initalize_patient_information_table => :environment do
    patients = Patient.all.includes("daily_reports")
    ActiveRecord::Base.transaction do
      patients.each do |patient|
        puts(".")
        if (patient.patient_information.nil?)
          dt_added = Channel.find_by(user_id: patient.id).created_at
          dt_started = patient.app_start || dt_added
          PatientInformation.create!(patient_id: patient.id, datetime_patient_added: dt_added, datetime_patient_activated: dt_started)
        end
      end
    end

    puts " All done now!"
  end
end
