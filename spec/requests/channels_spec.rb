require "rails_helper"

describe "get all patients route", :type => :request do
  before(:all) do
    @organization = FactoryBot.create(:organization)
    @practitioner = FactoryBot.create(:practitioner, organization: @organization)
    @patient = FactoryBot.create(:patient, treatment_start: DateTime.now())
  end

  # before do |example|
  #   unless example.metadata[:skip_login]
  #       cookie_for_user({ password: "password", email: @practitioner.email, type: "Practitioner" })
  #   end
  # end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "coordinator has access to patient channels and site channel" do

    cookie_for_user({ password: "password", email: @practitioner.email, type: "Practitioner" })
    get "/channels"
    parsed = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(parsed.length).to equal(2)
    expect(parsed[0]["title"]).to eq(@organization.title)
    expect(parsed[1]["title"]).to eq(@patient.full_name)
  end
  
  it "returns status code 401 when not authorized" do
    get "/channels"
    expect(response).to have_http_status(:unauthorized)
  end

  #cookie_for_user({ password: "password", phone_number: patient.phone_number, type: "Patient" })

end
