namespace :adherence do
  desc "Add new patient_information adherence fields 5/24/2021"
  task :initalize_pi_table => :environment do
    patient = Patient.all
    ActiveRecord::Base.transaction do
      patient.each do |patient|
        patient.patient_information.update_patient_stats
      end
    end

    puts " All done now!"
  end

  desc "Ensures 5/24/2021"
  task :ensure_activation_exists => :environment do
    pi = PatientInformation.where("datetime_patient_activated IS NULL")
    ActiveRecord::Base.transaction do
      pi.each do |p_i|
        p_i.update!(datetime_patient_activated: p_i.datetime_patient_added)
      end
    end

    puts " All done now!"
  end

  desc "Ensures 5/24/2021"
  task :dev_fix => :environment do
    return unless Rails.env.development?
    pi = PatientInformation.all
    ActiveRecord::Base.transaction do
      pi.each do |p_i|
        p_i.update!(datetime_patient_activated: p_i.datetime_patient_added)
      end
    end

    puts " All done now!"
  end

  desc "Migrate treatment_end_date -> app_end_date"
  task :migrate_end_date => :environment do
    return unless Rails.env.development?
    pi = PatientInformation.all
    ActiveRecord::Base.transaction do
      pi.each do |p_i|
        if (p_i.patient.archived?)
          p_i.update!(app_end_date: p_i.patient.treatment_end_date)
        end
      end
    end

    puts " All done now!"
  end
end
