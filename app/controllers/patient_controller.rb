require "fileutils"
require "base64"


class PatientController < ApplicationController
    before_action :auth_patient
    skip_before_action :verify_authenticity_token


    def auth_patient
    # def auth_participant
    #   #@decoded = decode_token
    #   @current_user = Participant.find(@decoded[:uuid])
  
    #   rescue ActiveRecord::RecordNotFound => e
    #     render json: { errors: "Unauthorized participant" }, status: :unauthorized
    #   end
    # end
    end

    def get_patient
        relevantPatient = Patient.find(params["patientID"]);
        render(json: relevantPatient.as_json, status: 200);
    end

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

        render(json: new_patient.as_json, status: 200)
    end


end