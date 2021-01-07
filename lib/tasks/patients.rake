require 'rest-client'

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

        DailyReport.all.delete_all
        PhotoReport.all.delete_all
        MedicationReport.all.delete_all
        SymptomReport.all.delete_all

        Patient.all.active.each do |patient|
          patient.seed_test_reports([true,true,false].sample)
          print "."
        end
        
        PhotoReport.joins(:daily_report).where('daily_reports.date < ?', DateTime.now() - 1.day).update_all(approved: true)
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


  desc "Transfer data"
  task :transfer_test_instance_data, [:url,:patient_id,:email,:password] => :environment do |t, args|

    response = RestClient.post("#{args[:url]}/auth", {email: args[:email],password: args[:password]})
    good_cookie = response.cookies
    
    reports = RestClient.get("#{args[:url]}/practitioner/patient/#{args[:patient_id]}",{:cookies => good_cookie})
    puts(reports.body)
  end

end
