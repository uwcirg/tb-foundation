require "swagger_helper"

describe "Patient Update Route" do
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

  path "v2/patient/{id}" do
    patch "Updates phone number" do
      tags "Patient"
      produces "application/json"
      consumes "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :patient, in: :body, schema: {
                  type: :object,
                  properties: {
                    givenName: { type: :string },
                    familyName: { type: :string },
                    phoneNumber: { type: :string },
                  },
                }

      response "201", "patient update successful" do
        schema type: :object,
               properties: {
                 givenName: { type: :string },
                 familyName: { type: :string },
                 phoneNumber: { type: :string },
                 createdAt: { type: :date },
               }

        let(:id) { @patients[0].id }
        run_test!
      end
    end
  end
end
