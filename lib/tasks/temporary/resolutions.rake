namespace :resolutions do
    desc "Initalize general resolutions"
    task :initalize_general => :environment do
      patients = Patient.all
      ActiveRecord::Base.transaction do
        patients.each do |patient|
          patient.resolutions.create!(kind: "General", resolved_at: Time.now - 1.day, practitioner: patient.organization.practitioners.first)
          print(".")
        end
      end
  
      puts " All done now!"
    end
  end
  