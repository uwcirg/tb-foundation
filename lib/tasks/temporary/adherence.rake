namespace :adherence do
  desc "Add new patient_information adherence fields 5/24/2021"
  task :initalize_pi_table => :environment do
    patient = Patient.all
    ActiveRecord::Base.transaction do
      patient.each do |patient|
        patient.patient_information.update_all_adherence_values
      end
    end

    puts " All done now!"
  end
end
