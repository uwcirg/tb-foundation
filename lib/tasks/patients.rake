require "rest-client"

namespace :patients do
  desc "Fix patient reports from inital launch downtime"
  task :fix_inital_reports => :environment do
    patients = Patient.where("treatment_start < TO_DATE('20201125','YYYYMMDD')")
    puts "Going to update #{users.count} patients"

    ActiveRecord::Base.transaction do
      puts(patient.treatment_start)
    end

    puts " All done now!"
  end

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
          patient.seed_test_reports([true, true, false].sample)
          print "."
        end

        PhotoReport.joins(:daily_report).where("daily_reports.date < ?", DateTime.now() - 1.day).update_all(approved: true)
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
          patient.create_seed_report(Date.today, [true, true, false].sample)
          print "."
        end
      end
    else
      puts("Can only be run in development - is destructive to patient data")
    end

    puts " All done now!"
  end

  desc "Transfer data"
  task :transfer_test_instance_data, [:live_patient_id, :url, :demo_patient_id, :email, :password] => :environment do |t, args|
    response = RestClient.post("#{args[:url]}/auth", { email: args[:email], password: args[:password] })
    good_cookie = response.cookies

    reports = RestClient.get("#{args[:url]}/patient/#{args[:demo_patient_id]}/json_reports", { :cookies => good_cookie })
    parsed = JSON.parse(reports)

    ActiveRecord::Base.transaction do

    patient = Patient.find(args[:live_patient_id])

    parsed[0..1].each do |report|

      if(!report["photo_report"].nil?)
        photo_report = report["photo_report"]
        photo_report["user_id"] =  patient.id

        medication_report = report["medication_report"]
        medication_report["user_id"] = patient.id

        symptom_report = report["symptom_report"]
        symptom_report["user_id"] = patient.id

        new_p = patient.photo_reports.create!(photo_report)
        new_m = patient.medication_reports.create!(medication_report)
        new_s = patient.symptom_reports.create!(symptom_report)

        report["photo_report"] = new_p
        report["medication_report"] = new_m
        report["symptom_report"] = new_s
        report["user_id"] = patient.id

        patient.daily_reports.create!(report)
      end

      end
    end

    
    # puts(parsed[1])
    # puts("Patient were adding reports for: ")
    # puts(Patient.find(args[:live_patient_id]).full_name)
  end
end
