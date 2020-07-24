require "aws-sdk"
require "securerandom"
   require 'sidekiq/web'

class PractitionerController < UserController
  before_action :auth_practitioner, :except => [:upload_lab_test, :generate_presigned_url, :get_all_tests]

  def get_current_practitioner
    render(json: @current_practitoner, status: 200)
  end

  def get_patient
    render(json: @current_practitoner.patients.find(params[:patient_id]), all_details: true, status: 200)
  end

  def create_pending_patient

    #This generates a random 4 digit hex
    code = SecureRandom.hex(10).upcase[0, 5]

    new_patient = Patient.create(
      phone_number: params[:phoneNumber],
      password_digest: BCrypt::Password.create(code),
      family_name: params[:familyName],
      given_name: params[:givenName],
      organization: @current_practitoner.organization,
      treatment_start: params["isTester"] ? DateTime.now() - 1.month : DateTime.now(),
      status: "Pending",
    )

    if new_patient.save

      if(params["isTester"] == true)
        new_patient.seed_test_reports
      end

      render(json: { account: new_patient, code: code }, status: 200)
    else
      @test = new_patient.errors.as_json
      @test = @test.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
      render(json: { error: 422, paramErrors: @test }, status: 422)
    end
  end

  def get_patients
    hash = {}
    pp = @current_practitoner.organization.patient_priorities
    @current_practitoner.patients.active.each do |patient|
      serialization = ActiveModelSerializers::SerializableResource.new(patient).as_json
      hash[patient.id] = serialization.merge({priority: pp[patient.id]})

    end
    render(json: hash, status: 200)
  end

  def get_temp_accounts
    temp_accounts = @current_practitoner.patients.pending
    render(json: temp_accounts, status: 200)
  end

  def generate_presigned_url
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket("lab-strips")
    key = "lab-test-#{SecureRandom.uuid}.jpeg"
    obj = bucket.object(key)
    url = obj.presigned_url(:put)

    render json: { url: url, key: key }
  end

  def get_all_tests
    render(json: LabTest.all().as_json, status: 200)
  end

  def upload_lab_test
    newTest = LabTest.create!(
      test_id: params[:testId],
      description: params[:description],
      photo_url: params[:photoURL],
      is_positive: params[:isPositive],
      test_was_run: params[:testWasRun],
      minutes_since_test: params[:minutesSinceTest],
    )

    signer = Aws::S3::Presigner.new
    url = signer.presigned_url(:get_object, bucket: "lab-strips", key: newTest.photo_url)

    render(json: newTest.as_json, status: 200)
  end

  def get_photos
    photos = @current_practitoner.get_photos
    render(json: photos, status: 200)
  end

  def get_historical_photos
    photos = @current_practitoner.get_historical_photos
    render(json: photos, status: 200)
  end

  def audit_photo
    photo = PhotoReport.find(params[:photo_id])

    if (photo.nil?)
      render(json: { error: "That Photo Does Not Exist" }, status: 422)
      return
    end

    if (params[:approved])
      photo.approve
    else (!params[:approved])
      photo.deny     
    end

    render(json: { message: "Photo status updated" }, status: 200)
  end

  def get_patient_reports
    patient = get_patient_by_id(params[:patient_id])

    if (patient.nil?)
      return
    end

    render(json: patient.formatted_reports, status: 200)
  end

  def patients_with_symptoms
    patients = []
      DailyReport.unresolved_symptoms.select("user_id").distinct.each do |patient|
        patients.push({"patientId": patient.user_id})
      end
    render(json: patients, status: 200)
  end

  def patients_missed_reporting
    list = @current_practitoner.patients_missed_medication
    render(json: list, status: 200)
  end

  def patients_with_adherence
    render(json: @current_practitoner.patients, status: 200)
  end

  def patient_symptom_summary
    render(json: @current_practitoner.patients.find(params["patient_id"]).symptom_summary, status: 200)
  end

  def recent_reports
    render(json: DailyReport.two_days.where(patient: @current_practitoner.patients).order("date DESC, updated_at DESC").limit(50), status: 200)
  end

  def create_resolution
    case params["type"]

    when "symptom"
      resolution = @current_practitoner.patients.find(params["patient_id"]).resolve_symptoms(@current_practitoner.id)
    when "medication"
      resolution = @current_practitoner.patients.find(params["patient_id"]).resolve_missing_report(@current_practitoner.id)
    else
      render(json: { error: "#{params["type"]} is not a resolution type", status: 422 })
    end

    render(json: resolution, status: 200)
  end

  def reset_temp_password
    code = SecureRandom.hex(10).upcase[0, 5]
    @current_practitoner.patients.find(params[:patient_id]).update_password(code)
    render(json: { newCode: code }, status: 200)
  end

  def patient_missed_days
    render(json: {last_resolved: Resolution.where(patient_id: params[:patient_id], kind: "MissedMedication").order("created_at DESC").first, days: get_patient_by_id(params[:patient_id]).missed_days}, status: 200)
  end

  private

  def get_patient_by_id(id)
    patient = @current_practitoner.patients.find(id)
  end
end
