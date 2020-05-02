# This file should create all of the records needed
# to seed the database with its default values.
# The data can then be loaded
# with the rails db:seed command
# (or created alongside the database with db:setup).

#Organization.create(title: "University of Washington")
#Organization.create(title: "Hospital One")

case Rails.env
when "development"
    password_hash = BCrypt::Password.create(ENV["RAILS_BASE_PASS"])

    #Organizations
    Organization.create(title: "University of Washington")
    Organization.create(title: "Hospital One")

    #Test Practitioner
    practitioner = Practitioner.create!(
        password_digest: password_hash,
        family_name: "Practitioner",
        given_name: "Test",
        managing_organization: "Hospital One",
        email: "test@gmail.com",
        type: "Practitioner"
    )

    #Test Patient
    patient = Patient.create!(
        password_digest: password_hash,
        family_name: "Goodwin",
        given_name: "Kyle",
        managing_organization: "Hospital One",
        phone_number: "123456789",
        treatment_start: Date.today - 2.months,
        type: "Patient",
        practitioner_id: practitioner.id
    )

    #Test Patient
    newPatient = Patient.create!(
        password_digest: password_hash,
        family_name: "Brown",
        given_name: "Jimmy",
        managing_organization: "Hospital One",
        phone_number: "012345678",
        treatment_start: Date.today - 2.months,
        type: "Patient",
        practitioner_id: practitioner.id
    )

    #Test Patient
    patient2 = Patient.create!(
        password_digest: password_hash,
        family_name: "Prueba",
        given_name: "Hugo",
        managing_organization: "Hospital One",
        phone_number: "111222333",
        treatment_start: Date.today - 1.month,
        type: "Patient",
        practitioner_id: practitioner.id
    )

    patient.seed_test_reports
    patient.photo_day_override
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
        managing_organization: "Hospital One",
        type: "Administrator",
      )


    gc = admin.channels.create!(title: "General Channel",subtitle: "Channel for general discussion")
    sc = admin.channels.create!(title: "Symptom Channel",subtitle: "Channel for symptom discussion")


    #Messages
    i = 0
    loop do
        i = i + 1;

        admin.messages.create!(body: "Test message from seed for channel TEST",channel_id: gc.id)
        admin.messages.create!(body: "Test message from seed for channel 2",channel_id: sc.id)
        patient.messages.create!(body: "Patient test 1",channel_id: gc.id,user_id: admin.id)
        patient.messages.create!(body: "Patient test 1 two",channel_id: gc.id)
        patient.messages.create!(body: " Patient one, This is a very long message. It is supposed to take up mulitple lines. Hopefully thi swill work. I hope that this takes up multiple lines so that I can see what that might look like. I wonder if I should be using some other type of storage for this instead of just a string. What is a good db field for multiline input?",channel_id: gc.id)
        admin.messages.create!(body: "This is a very long message. It is supposed to take up mulitple lines. Hopefully thi swill work. I hope that this takes up multiple lines so that I can see what that might look like. I wonder if I should be using some other type of storage for this instead of just a string. What is a good db field for multiline input?",channel_id: sc.id)
        patient.messages.create!(body: "Patient test 2",channel_id: sc.id)

        if(i > 5)
            break
        end
    end

    practitioner.messages.create!(body: "Latest Test message for 1",channel_id: gc.id)

    patient3 = Patient.create!(
        password_digest: password_hash,
        family_name: "Patient 3",
        given_name: "Test",
        managing_organization: "Hospital One",
        phone_number: "123456780",
        treatment_start: Date.today,
        type: "Patient",
        practitioner_id: practitioner.id
    )

    #Patient.create!(password_digest: BCrypt::Password.create(ENV["RAILS_BASE_PASS"]), family_name: "Patient 3", given_name: "Test", managing_organization: "Hospital One", phone_number: "123456781",treatment_start: Date.today,type: "Patient")
    #Channel.create(title: "TEST",user_id: 6)

    #TODO For each patient generate a treatment report ( but skip some days )

    

when "production"
end