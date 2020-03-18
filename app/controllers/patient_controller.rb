require "fileutils"
require "base64"

class PatientController < UserController
    before_action :auth_patient, :except => [:activate_patient,:check_patient_code]

    def auth_patient
      @decoded = decode_token
      @current_user = Patient.find(@decoded[:user_id])
  
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: "Unauthorized participant" }, status: :unauthorized
    end

    def get_patient
        render(json: @current_user.as_fhir_json, status: 200);
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

    def activate_patient

        if(check_patient_activation_code && confirm_password)
            
             @user = Patient.create(
                given_name: @temp_account.given_name,
                family_name: @temp_account.family_name,
                username: params["username"],
                password_digest: BCrypt::Password.create(params["password"]),
                phone_number: @temp_account.phone_number,
                managing_organization: @temp_account.organization,
                treatment_start: @temp_account.treatment_start)

            if(@user.valid?)
                authenticate()
            else
                render(json: @user.errors.to_json, status: 400)
            end

        end
    end

    def check_patient_code
        if(check_patient_activation_code)
            render(json: {validCode: true}, status: 200)
        else
            render(json: {validCode: false}, status: 400)
        end
    end 

    private

    def check_patient_activation_code
        @temp_account = TempAccount.where( phone_number: params["phoneNumber"]).first();
        if(@temp_account && BCrypt::Password.new(@temp_account.code_digest) == params["activationCode"])
            return true
        else
            render(json: {error: "Incorrect Activation Code"}, status: 401)
        end
    end


end