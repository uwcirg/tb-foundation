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

    desc "Add Age / Gender to patietns missing it"
    task :add_age_gender => :environment do
      users = Patient.all
      puts "Going to update #{users.count} patients"
  
      ActiveRecord::Base.transaction do
        users.each do |patient|
          if(patient.gender.nil?)
            patient.update!(gender: [0,1,2].sample)
          end

          if(patient.age.nil?)
            patient.update!(age: rand(18..70))
          end
          print "."
        end
      end
  
      puts " All done now!"
    end
  end