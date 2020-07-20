FactoryBot.define do

    orgs_array = ["Test Organization", "UW"]

    factory :practitioner do
        given_name { Faker::Name.first_name }
        family_name { Faker::Name.last_name }
        email { Faker::Internet.email }
        password_digest { BCrypt::Password.create("password") }
      end

    factory :organization do
        title { orgs_array.sample}
    end

    factory :random_patients, class: Patient do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    phone_number { Faker::Number.number(digits: 9).to_s }
    password_digest { BCrypt::Password.create("password") }
    treatment_start { Faker::Date.between(from: 1.month.ago, to: Date.today) }
  end
end
