require "rails_helper"


describe "get all patients route", :type => :request do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
    @patients = FactoryBot.create_list(:random_patients, 3, organization: @organization)
  end

  before do |example|
    unless example.metadata[:skip_login]
        cookie_for_user({ password: "password", email: @practitioner.email, type: "Practitioner" })
    end
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "returns status code 401 when not authorized",skip_login: true do
    get "/practitioner/patients"
    expect(response).to have_http_status(:unauthorized)
  end

  it "gets patient list" do
    get "/practitioner/patients"
    expect(response).to have_http_status(:success)
  end

  it "expect length of response to be 3 patients" do
    get "/practitioner/patients"
    expect(JSON.parse(response.body).length).to equal(3)
  end

  it "401 for patient when not authorized", skip_login: true do
    get "/patient/#{@patients.first.id}/reports"
    expect(response).to have_http_status(:unauthorized)
  end


end
