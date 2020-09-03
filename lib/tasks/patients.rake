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
        if (patient.gender.nil?)
          patient.update!(gender: [0, 1, 2].sample)
        end

        if (patient.age.nil?)
          patient.update!(age: rand(18..70))
        end
        print "."
      end
    end

    puts " All done now!"
  end

  desc "Create Support Resolution"
  task :add_need_support => :environment do
    users = Patient.all
    puts "Going to update #{users.count} patients"

    ActiveRecord::Base.transaction do
      users.each do |patient|
        patient.resolutions.create!(kind: "NeedSupport", resolved_at: DateTime.now() - 3.days, practitioner: (Practitioner.all.first))
        print "."
      end
    end

    puts " All done now!"
  end

  desc "Generate Reporting History"
  task :generate_test_reports => :environment do
    if (Rails.env == "development")
      ActiveRecord::Base.transaction do
        Patient.all.active.each do |patient|
          patient.daily_reports.destroy_all
          patient.seed_test_reports([true,true,false].sample)
          print "."
        end
      end
    else
      puts("Can only be run in development - is destructive to patient data")
    end

    puts " All done now!"
  end

  desc "Report for today"
  task :report_for_today => :environment do
    if (Rails.env == "development")
      ActiveRecord::Base.transaction do
        Patient.all.active.each do |patient|
          patient.create_seed_report(Date.today, [true,true,false].sample)
          print "."
        end
      end
    else
      puts("Can only be run in development - is destructive to patient data")
    end

    puts " All done now!"
  end

end
