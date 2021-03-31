require "swagger_helper"

describe "Patient Update Route" do
  before(:each) do
    create_first_organization
    @id = @patients[0].id
  end

  before do |example|
    unless example.metadata[:skip_login]
      cookie_for_user({ password: "password", email: @practitioner.email })
    end
  end

  after(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  path "/v2/patient/{id}" do
    patch "Updates phone number" do
      tags "Patient"
      produces "application/json"
      consumes "application/json"
      parameter name: :id, in: :path, type: :string
      parameter name: :update_patient, in: :body, schema: { '$ref' => '#/components/schemas/update_patient' }

      response "201", "patient update successful" do
        schema "$ref" => "#/components/schemas/patient"
        let!(:id) { @patients[0].id }
        let!(:new_phone){Faker::Number.number(digits: 9).to_s}
        let!(:update_patient){
          {phone_number: new_phone}
        }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["phoneNumber"]).to eq(new_phone)
        end
      end
    end
  end
end
