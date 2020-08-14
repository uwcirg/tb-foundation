class Patient::PatientsController < UserController
  before_action :snake_case_params
  before_action :auth_practitioner

  def create
    patient_hash = patient_params
    is_test_account = patient_params[:is_tester]
    code = SecureRandom.hex(10).upcase[0, 5]
    patient_hash.delete(:is_tester)
    new_patient = @current_user.organization.add_pending_patient(patient_hash, code)

    #TODO Remove this code after usability testing is complete
    if new_patient.save

      if is_test_account && Rails.env.development?
        new_patient.update!(treatment_start: DateTime.now() - 1.month)
        new_patient.seed_test_reports
        new_patient.photo_day_override
      end

      render(json: { account: new_patient, code: code }, status: 200)
    else
      errors = new_patient.errors.as_json
      errors = errors.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
      render(json: { error: 422, paramErrors: errors }, status: 422)
    end

    #This generates a random 4 digit hex
    # code = SecureRandom.hex(10).upcase[0, 5]

    # new_patient = Patient.create(
    #   phone_number: params[:phoneNumber],
    #   password_digest: BCrypt::Password.create(code),
    #   family_name: params[:familyName],
    #   given_name: params[:givenName],
    #   organization: @current_practitoner.organization,
    #   treatment_start: params["isTester"] ? DateTime.now() - 1.month : DateTime.now(),
    #   status: "Pending",
    # )

    # if new_patient.save

    #   if(params["isTester"] == true)
    #     new_patient.seed_test_reports
    #     new_patient.photo_day_override
    #   end

    #   render(json: { account: new_patient, code: code }, status: 200)
    # else
    #   @test = new_patient.errors.as_json
    #   @test = @test.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
    #   render(json: { error: 422, paramErrors: @test }, status: 422)
    # end
  end

  private

  def patient_params
    params.permit(:phone_number, :family_name, :given_name, :treatment_start, :is_tester)
  end
end
