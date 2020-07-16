# lib/tasks/temporary/users.rake
namespace :patients do
    desc "Create PhotoSchedule for each patient"
    task :set_photo_schedule => :environment do
      users = Patient.all
      puts "Going to update #{users.count} patients"
  
      ActiveRecord::Base.transaction do
        users.each do |user|
          user.generate_photo_schedule
          print "."
        end
      end
  
      puts " All done now!"
    end
  end