require "rails_helper"

describe "get all patients route", :type => :request do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @organization2 = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
    @practitioner2 = FactoryBot.create(:practitioner, organization: @organization2)
    @patients = FactoryBot.create_list(:random_patients, 3, organization: @organization)
    @patients2 = FactoryBot.create_list(:random_patients, 3, organization: @organization2)
  end

  before do |example|
    unless example.metadata[:skip_login]
      cookie_for_user({ password: "password", email: @practitioner.email, type: "Practitioner" })
    end
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "cant access other organizations" do
    get "/organizations/2/patients"
    expect(response).to have_http_status(:unauthorized)
  end

  it "Deny access to organizations that dont exist" do
    get "/organizations/3/patients"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns status code 401 when not authorized", skip_login: true do
    get "/organizations/1/patients"
    expect(response).to have_http_status(:unauthorized)
  end

  it "gets patient list" do
    get "/organizations/1/patients"
    expect(response).to have_http_status(:success)
  end

  it "expect length of response to be 3 patients" do
    get "/organizations/1/patients"
    parsed = JSON.parse(response.body)
    expect(parsed.length).to equal(3)
  end

  it "expect 2nd patient to be the same" do
    get "/organizations/1/patients"
    parsed = JSON.parse(response.body)
    left = parsed[0]["givenName"]
    right = Organization.find(1).patients[0]["given_name"]
    expect(left).to eq(right)
  end

end
