Patient.all.each do |patient|
    patient.generate_photo_schedule()
    p(patient.full_name)
  end
end

