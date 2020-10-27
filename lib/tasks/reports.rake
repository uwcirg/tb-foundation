# lib/tasks/temporary/users.rake
namespace :reports do
    desc "Add dates onto report types"
    task :fix_unread_messages => :environment do
      
        symptom_reports = SymptomReport.all
        medication_reports = MedicationReport.all
        photo_reports = PhotoReport.all

      puts "Going to update all reports with dates"
      ActiveRecord::Base.transaction do
        symptom_reports.each do |symptom|
            symptom.update!(date: symptom.created_at.to_date)
        end

        medication_reports.each do |medication|
            medication.update!(date: medication.created_at.to_date)
        end

        photo_reports.each do |photo|
            photo.update!(date: photo.captured_at ? photo.captured_at.to_date : Date.current )
        end
      end
  
      puts " All done now!"
    end
  end
  