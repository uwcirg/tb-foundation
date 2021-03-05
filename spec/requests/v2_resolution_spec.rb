require "rails_helper"

HEADERS = { "CONTENT_TYPE" => "application/json" }

describe "POST v2/resolution", :type => :request do
  before(:all) do
    create_first_organization
  end

  before do |example|
    unless example.metadata[:skip_login]
      cookie_for_user({ password: "password", email: @practitioner.email })
    end
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "returns status code 401 when not authorized", skip_login: true do
    post "/v2/resolutions"
    expect(response).to have_http_status(:unauthorized)
  end

  it "requires a patient id, resolution time, and kind" do
    post "/v2/resolutions", :params => '{ "patientId": 3}', :headers => HEADERS
    expect(response.status).to eq(400)

    post "/v2/resolutions", :params => '{ "patientId": 3, "resolvedAt": "2021-02-10T11:58:13.812-05:00"}', :headers => HEADERS
    expect(response.status).to eq(400)

    post "/v2/resolutions", :params => '{ "patientId": 3, "resolvedAt": "2021-02-10T11:58:13.812-05:00", "kind": "Symptom"}', :headers => HEADERS
    expect(response.status).to eq(200)
  end

  it "will not let non-practitioners access this route", skip_login: true do
    cookie_for_user({ password: "password", phone_number: @patients[0].phone_number })
    post "/v2/resolutions", :params => '{ "patientId": 3, "resolvedAt": "2021-02-10T11:58:13.812-05:00", "kind": "Symptom"}', :headers => HEADERS
    expect(response.status).to eq(401)
  end

  #   it "will return an error when a patient does not exist, do"

end
