namespace :photo_schedule do
  desc "Deletes all scheduled photos after current week. Creates new scheudle at 2 per week"
  task :fix_future_schedule => :environment do
    users = Patient.all
    puts "Going to update #{users.count} patients photo schedule"

    ActiveRecord::Base.transaction do
      weekdays_array = (1..5).to_a

      users.each do |patient|

        #Delete future requests, starting next week
        patient.photo_days.where("date > ?", Date.today.end_of_week).destroy_all
        date = patient.treatment_start
        i = 0

        while i < (28)
          weekly_photo_sum = 1

          #Move to Sunday, so we can add weekday to get randomized day
          date = date.beginning_of_week(start_day = :sunday)

          #Select randomized weekdays from array
          selected_weekdays = weekdays_array.shuffle.take(weekly_photo_sum)
          end_week = date.end_of_week(start_day = :sunday)

          #Map these weekdays to DB rows
          selected_weekdays.each do |weekday|
            new_date = date + weekday.days

            #Only change days after this week
            if (new_date > Date.today.end_of_week(start_day = :sunday))
              patient.photo_days.create!(date: new_date)
            end
          end
          date = date + 1.week
          i += 1
        end
        puts "Patient #{patient.id} done now!"
      end
    end
  end

  desc "Create inital photo resolutions for new task list"
  task :initalize_missed_photo_resolution => :environment do
    ActiveRecord::Base.transaction do
      Patient.all.each do |patient|
        patient.resolutions.create!(practitioner_id: patient.organization.practitioners.first.id , kind: "MissedPhoto", resolved_at: DateTime.now - 5.days)
        puts("Patient #{patient.id} done")
      end
    end
  end

end
