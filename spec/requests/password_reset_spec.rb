require "rails_helper"

HEADERS = { "CONTENT_TYPE" => "application/json" }

describe "POST patient/:patient_id/password-reset", :type => :request do
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
    post "/patient/#{@patients[0].id}/password-reset"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns a new password 5 characters long" do
    post "/patient/#{@patients[0].id}/password-reset"
    expect(JSON.parse(response.body)["temporaryPassword"].length).to equal(5)
    expect(response).to have_http_status(:created)
  end

#   it "updates users state of password once reset" do
#     post "/patient/#{@patients[0].id}/password-reset"
#     expect(@patients[0].has_temp_password).to equal(true)
#   end
end
