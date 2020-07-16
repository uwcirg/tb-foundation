
weekdays_array = (1..5).to_a
Patient.all.each do |patient|
  date = patient.treatment_start
  i = 0
  while i < (28)

    #Decide How Many Treatment days will occur this week
    i < 8 ? mod = 0 : mod = 1
    weekly_photo_sum = rand(2 - mod..3 - mod)

    #Move to Sunday, so we can add weekday to get proper day
    date = date.beginning_of_week(start_day = :sunday)
    selected_weekdays = weekdays_array.shuffle.take(weekly_photo_sum)

    #Map these weekdays to DB rows
    selected_weekdays.each do |weekday|
        patient.photo_days.create!(date: date + weekday.days)
    end

    date = date + 1.week
    i += 1
  end

end

