# spec/models/auction_spec.rb
require "rails_helper"

RSpec.describe Practitioner, :type => :model do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe ".patients_missed_photo_days" do
    let(:patient) { FactoryBot.create(:patient, treatment_start: DateTime.now()) }

    #A patient that missed a photo day yesterday shows up

    #If a photo was submitted today, it wont show up

    #If it wasn't a photo day it wont show up 

    #If they left a reason that will be included in the response

    #Only show ones since last resolution

    #Other cases

  end

end
