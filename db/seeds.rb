# This file should create all of the records needed
# to seed the database with its default values.
# The data can then be loaded
# with the rails db:seed command
# (or created alongside the database with db:setup).

#Organization.create(title: "University of Washington")
#Organization.create(title: "Hospital One")

first_names = ["Santiago","Mateo","Juan","Matias","Nicolas","Benjamin","Pedro","Tomas","Thiago","Santino"]
last_names = ["Gonzalez","Rodriguez","Fernandez","Lopez","Gomez","Martinez","Garcia","Diaz","Perez","Sanchez"]

case Rails.env
when "development"
    password_hash = BCrypt::Password.create(ENV["RAILS_BASE_PASS"])

    #Organizations
    org_one = Organization.create!(title: "University of Washington")
    Organization.create!(title: "Hospital One")

    #Test Practitioner
    practitioner = Practitioner.create!(
        password_digest: password_hash,
        family_name: "Practitioner",
        given_name: "Test",
        organization_id: org_one.id,
        email: "test@gmail.com",
        type: "Practitioner"
    )

    #Test Practitioner
    practitioner_two = Practitioner.create!(
        password_digest: password_hash,
        family_name: "Hugo",
        given_name: "Test",
        organization_id: org_one.id,
        email: "test@test.com",
        type: "Practitioner"
    )

    #Test Patient
    patient = Patient.create!(
        password_digest: password_hash,
        family_name: "Goodwin",
        given_name: "Kyle",
        organization_id: org_one.id,
        phone_number: "123456789",
        treatment_start: Date.today - 2.months,
        type: "Patient"
    )


    #Test Patient
    newPatient = Patient.create!(
        password_digest: password_hash,
        family_name: "Brown",
        given_name: "Jimmy",
        organization_id: org_one.id,
        phone_number: "012345678",
        treatment_start: Date.today - 2.months,
        type: "Patient"
        
    )

    #Test Patient
    patient2 = Patient.create!(
        password_digest: password_hash,
        family_name: "Prueba",
        given_name: "Hugo",
        organization_id: org_one.id,
        phone_number: "111222333",
        treatment_start: Date.today - 1.month,
        type: "Patient"
        
    )

    patient.patient_information.update!(datetime_patient_activated: Time.current - 2.months )
    patient.seed_test_reports(true)
    patient.photo_day_override
    patient.patient_information.update_patient_stats

    newPatient.seed_test_reports
    newPatient.photo_day_override
    patient2.seed_test_reports
    patient2.photo_day_override

    #Test Admin
    admin = Administrator.create!(
        email: :"admin@gmail.com",
        password_digest: password_hash,
        family_name: "Admin",
        given_name: "Test",
        organization_id: org_one.id,
        type: "Administrator"
      )


    gc = admin.channels.create!(title: "Discusión General",subtitle: "Un lugar para discusión general")
    sc = admin.channels.create!(title: "Romper el hielo",subtitle: "Que les parece esta oportunidad de poder compartir este foro?")
    ib = admin.channels.create!(title: "Mejoras en la aplicación",subtitle: "Quién mejor sabe cómo mejorar la aplicación es quien la usa, por eso te invito a dejar tu propuesta de mejora y que los demás participantes puedan ver tu idea.")
    
    #Messages
    i = 0
    loop do
        i = i + 1;
        admin.send_message_no_push("Hola", gc.id)
        admin.send_message_no_push("Que tal", sc.id)
        patient.send_message_no_push("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur?",gc.id)
        patient.send_message_no_push("Patient test 2",channel_id: gc.id)

        admin.send_message_no_push("Hola a todos, soy Admin y estoy probando esta función. Saludos a todos",sc.id)
        patient.send_message_no_push("Probando dos",gc.id)

        if(i > 5)
            break
        end
    end

    practitioner.send_message_no_push("Latest Test message for 1",gc.id)

    i = 0
    first_names.each do |name|
        rand_weeks = rand(1..24).weeks
        new_patient = Patient.create!(
            password_digest: password_hash,
            family_name: last_names[i],
            given_name: name,
            organization_id: org_one.id ,
            phone_number: "12312312#{i}",
            treatment_start: Date.today - rand_weeks,
            type: "Patient"
            
        )
        new_patient.patient_information.update!(datetime_patient_activated: Time.current - rand_weeks )
        new_patient.seed_test_reports(true)
        new_patient.patient_information.update_patient_stats
        i += 1
    end

    Patient.all.each do | patient |
        patient.update_stats_in_background
    end

    PhotoReport.all.update_all(approved: true)
    PhotoReport.last(3).each do | report |
        report.update!(approved: nil)
    end

when "production"
end    
