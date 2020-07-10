Resolution.destroy_all

Patient.all.each do |patient|
    one = patient.resolutions.create(practitioner: patient.organization.practitioners.first,kind: "MissedMedication")
    two = patient.resolutions.create(practitioner: patient.organization.practitioners.first,kind: "Symptom")
    three = patient.resolutions.create(practitioner: patient.organization.practitioners.first,kind: "MissedPhoto")

    one.updated_at = patient.treatment_start
    two.updated_at = patient.treatment_start
    three.updated_at = patient.treatment_start
    one.save
    two.save
    three.save
end
