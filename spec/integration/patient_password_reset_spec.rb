require "swagger_helper"

describe "Patient Password Reset Route" do
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

  path "/patient/{id}/password-reset" do
    
    post "Resets a patients password" do
      tags "Password"
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "201", "password reset successful" do
        schema type: :object,
               properties: {
                 temporaryPassword: { type: :string },
               },
               required: ["temporaryPassword"]

        let(:id) { @patients[0].id }
        run_test!
      end

      response "401", "password reset unauthorized", skip_login: true do
        schema type: :object,
               properties: {
                 status: {type: :integer},
                 error: {type: :string}
               }

        let(:id) { @patients[0].id }
        run_test!
      end
    end
  end
end
