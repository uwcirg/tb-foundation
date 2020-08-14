module SeedPatient
  
  def seed_test_reports(is_good = false)
   
    (treatment_start.to_date..DateTime.current.to_date).each do |day|
      #Decide if the user will report at all that day
      if (is_good)
        should_report = true
      else
        should_report = [true, true, true, true, false].sample
      end

      if (should_report)
        create_seed_report(day, is_good)
      end
    end
  end

  def create_seed_report(day, is_good)
    datetime = DateTime.new(day.year, day.month, day.day, 4, 5, 6, "-04:00")

    #TODO Fix
    is_photo_day = self.photo_days.where(date: day).exists?

    if(!is_good)
      med_report = MedicationReport.create!(user_id: self.id, medication_was_taken: [true, true, true, true, false, false].sample, datetime_taken: datetime)
      symptom_report = SymptomReport.create!(
        user_id: self.id,
        nausea: [true, false].sample,
        nausea_rating: [true, false].sample,
        redness: [true, false].sample,
        hives: [true, false].sample,
        fever: [true, false].sample,
        appetite_loss: [true, false].sample,
        blurred_vision: [true, false].sample,
        sore_belly: [true, false].sample,
        other: "Other symptom",
      )
    else
      med_report = MedicationReport.create!(user_id: self.id, medication_was_taken: [true, true, true, true, true, false].sample, datetime_taken: datetime)
      symptom_report = SymptomReport.create!(user_id: self.id, redness: [true, false, false, false, false, false].sample)
    end

    if(is_photo_day)
      photo_report = PhotoReport.create!(user_id: self.id, photo_url: "test_photo.jpg")
    end


    new_report = DailyReport.create(date: day, user_id: self.id,doing_okay: [true,true,true,false].sample)
    new_report.medication_report = med_report
    new_report.symptom_report = symptom_report
    new_report.photo_report = photo_report
    new_report.save
  end

end
