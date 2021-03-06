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
    puts(Organization.all.pluck(:id))

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

    patient.seed_test_reports(true)
    patient.photo_day_override
    newPatient.seed_test_reports
    newPatient.photo_day_override
    patient2.seed_test_reports
    patient2.photo_day_override

 ["Santiago","Mateo","Juan","Matias","Nicolas","Benjamin","Pedro","Tomas","Thiago","Santino"]
 ["Gonzalez","Rodriguez","Fernandez","Lopez","Gomez","Martinez","Garcia","Diaz","Perez","Sanchez"]

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
        # patient.messages.create!(body: "Patient test 1 two",channel_id: gc.id)
        # patient.messages.create!(body: " Patient one, This is a very long message. It is supposed to take up mulitple lines. Hopefully thi swill work. I hope that this takes up multiple lines so that I can see what that might look like. I wonder if I should be using some other type of storage for this instead of just a string. What is a good db field for multiline input?",channel_id: gc.id)
        # admin.messages.create!(body: "This is a very long message. It is supposed to take up mulitple lines. Hopefully thi swill work. I hope that this takes up multiple lines so that I can see what that might look like. I wonder if I should be using some other type of storage for this instead of just a string. What is a good db field for multiline input?",channel_id: sc.id)
        # patient.messages.create!(body: "Patient test 2",channel_id: sc.id)

        if(i > 5)
            break
        end
    end

    practitioner.send_message_no_push("Latest Test message for 1",gc.id)

    patient3 = Patient.create!(
        password_digest: password_hash,
        family_name: "Patient 3",
        given_name: "Test",
        organization_id: org_one.id,
        phone_number: "123456780",
        treatment_start: Date.today,
        type: "Patient"
        
    )

    i = 0
    first_names.each do |name|
        new_patient = Patient.create!(
            password_digest: password_hash,
            family_name: last_names[i],
            given_name: name,
            organization_id: org_one.id ,
            phone_number: "12312312#{i}",
            treatment_start: Date.today - rand(1..24).weeks,
            type: "Patient"
            
        )
        new_patient.seed_test_reports(true)
        i += 1
    end



    

when "production"
end    
