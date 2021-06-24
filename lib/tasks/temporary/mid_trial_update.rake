namespace :mid_trial_update do
  desc "Delete Extra PatientInformation entries"
  task :fix_patient_information_duplication => :environment do
    patients = Patient.all
    ActiveRecord::Base.transaction do
      patients.each do |patient|
        information_entries = PatientInformation.where(patient_id: patient.id)
        next unless information_entries.length > 1
        puts("Deleting entries for patient #{patient.id}")
        best_entry = information_entries.where("datetime_patient_activated is not null").first
        information_entries.where.not(id: best_entry.id).destroy_all
      end
    end

    puts " All done now!"
  end
end
