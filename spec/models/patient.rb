# spec/models/auction_spec.rb
require "rails_helper"

RSpec.describe Patient, :type => :model do
  it "is valid with valid attributes" do
    expect(Patient.new).to_not be_valid
  end

  it "patient with first,last, phone, treatment start is valid" do
    patient = Patient.create(given_name: "Test",family_name: "User",phone_number: 911811711, treatment_start: Date.today, password_digest: BCrypt::Password.create("password"))
    expect(patient).to be_valid
  end

  it "patient creates photo schedule, with at least one entry per week" do
    patient = Patient.create!(given_name: "Test",family_name: "User",phone_number: 911811711, treatment_start: Date.today, password_digest: BCrypt::Password.create("password"))
    puts(patient.photo_days.length)
    expect(patient.photo_days.length).to be >= 28
  end

  it "patient with bad phone number not valid" do
    patient = Patient.create(given_name: "Test",family_name: "User",phone_number: 911, treatment_start: Date.today, password_digest: BCrypt::Password.create("password"))
    expect(patient).to_not be_valid
  end

  
end
