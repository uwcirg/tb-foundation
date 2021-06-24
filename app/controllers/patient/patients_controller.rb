class Patient::PatientsController < UserController
  before_action :snake_case_params
  before_action :auth_practitioner

  def index
    render(json: @current_practitoner.patients, each_serializer: PatientShortSerializer, status: :ok)
  end

  def create
    patient_hash = patient_params
    is_test_account = patient_params[:is_tester]
    code = SecureRandom.hex(10).upcase[0, 5]
    patient_hash.delete(:is_tester)
    new_patient = @current_user.organization.add_pending_patient(patient_hash, code)

    #On dev instances allow seeding of data for training + testing
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
  end

  private

  def patient_params
    params.permit(:phone_number, :family_name, :given_name, :treatment_start, :is_tester)
  end
end
