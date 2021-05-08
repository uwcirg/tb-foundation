module PhotoSchedule
  def generate_schedule(patient, random = true)

    #Reset Scheudle
    patient.photo_days.destroy_all

    #Monday-Friday
    weekdays_array = (1..5).to_a

    date = patient.treatment_start
    i = 0
    while i < (28)
      if (!random)
        every_day_schedule(patient, date)
      else
        #Decide How Many Treatment days will occur this week
        weekly_photo_sum = 1

        #Move to Sunday, so we can add weekday to get proper day
        date = date.beginning_of_week(start_day = :sunday)
        selected_weekdays = weekdays_array.shuffle.take(weekly_photo_sum)

        #Map these weekdays to DB rows
        selected_weekdays.each do |weekday|
          patient.photo_days.create!(date: date + weekday.days)
        end
      end

      date = date + 1.week
      i += 1
    end
  end

  def every_day_schedule(patient, date)
    (0..6).to_a.each do |day|
      patient.photo_days.create!(date: date + day.days)
    end
  end
end
