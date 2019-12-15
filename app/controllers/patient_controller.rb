require "fileutils"
require "base64"


class PatientController < ApplicationController
    #before_action :auth_participant
    skip_before_action :verify_authenticity_token

    def new_patient

        password_hash = BCrypt::Password.create(params["password"])

        new_patient = Patient.create!(
            password_digest: password_hash,
            family_name: params["familyName"],
            given_name: params["givenName"],
            managing_organization: "test",
            phone_number: params["phoneNumber"],
            treatment_start: Date.today
        )

        render(json: new_patient.as_fhir_json, status: 200)
    end


end