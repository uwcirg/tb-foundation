FactoryBot.define do

  # factory :patient_information do
  #   datetime_patient_activated {Time.now}
  # end

  factory :push_notification_status do
    sent_successfully { false }
    delivered_successfully { false }
    clicked { false }
    clicked_at { "2021-05-03 17:09:08" }
  end


  orgs_array = ["Test Organization", "UW"]

  factory :practitioner do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password_digest { BCrypt::Password.create("password") }
  end

  factory :organization do
    title { Faker::University.name }
  end

  #Needs passed in organization
  factory :patient, class: Patient do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    phone_number { Faker::Number.number(digits: 9).to_s }
    password_digest { BCrypt::Password.create("password") }
    treatment_start { Faker::Date.between(from: 1.month.ago, to: Date.today) }
  end

  factory :random_patients, class: Patient do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    phone_number { Faker::Number.number(digits: 9).to_s }
    password_digest { BCrypt::Password.create("password") }
    treatment_start { Faker::Date.between(from: 1.month.ago, to: Date.today) }
  end

end
