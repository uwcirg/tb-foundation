require "fileutils"
require "base64"

class PatientController < UserController
  before_action :auth_patient, :except => [:activate_patient, :check_patient_code]

  def get_patient
    render(json: @current_user, status: 200)
  end

  def activate_patient
    if (check_patient_activation_code && confirm_password)
      @user = Patient.create(
        given_name: @temp_account.given_name,
        family_name: @temp_account.family_name,
        username: params["username"],
        password_digest: BCrypt::Password.create(params["password"]),
        phone_number: @temp_account.phone_number,
        managing_organization: @temp_account.organization,
        treatment_start: @temp_account.treatment_start,
        practitioner_id: @temp_account.practitioner_id,
      )

      if (@user.valid?)
        authenticate()
      else
        render(json: @user.errors.to_json, status: 400)
      end
    end
  end

  def new_patient
    password_hash = BCrypt::Password.create(params["password"])

    new_patient = Patient.create!(
      password_digest: password_hash,
      family_name: params["familyName"],
      given_name: params["givenName"],
      managing_organization: "test",
      phone_number: params["phoneNumber"],
      treatment_start: Date.today,
    )

    render(json: new_patient.as_json, status: 200)
  end

  def generate_upload_url
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket("patient-test-photos")
    key = "strip-photo-#{SecureRandom.uuid}.jpeg"
    obj = bucket.object(key)
    url = obj.presigned_url(:put)
    render(json: { url: url, key: key })
  end

  def get_patient_reports
    reports = @current_user.formatted_reports
    render(json: reports)
  end

  def post_daily_report
    med_report = MedicationReport.create!(user_id: @current_user.id, medication_was_taken: params["medicationWasTaken"], datetime_taken: params["dateTimeTaken"], why_medication_not_taken: params["whyMedicationNotTaken"])
    symptom_report = SymptomReport.create!(user_id: @current_user.id,
                                           nausea: params["nausea"],
                                           nausea_rating: params["nausea_rating"],
                                           redness: params["redness"],
                                           hives: params["hives"],
                                           fever: params["fever"],
                                           appetite_loss: params["appetite_loss"],
                                           blurred_vision: params["blurred_vision"],
                                           sore_belly: params["sore_belly"],
                                           yellow_coloration: params["yellow_coloration"],
                                           difficulty_breathing: params["difficulty_breathing"],
                                           facial_swelling: params["facial_swelling"],
                                           dizziness: params["dizziness"],
                                           headache: params["headache"],
                                           other: params["other"])

    photo_report = nil
    if (!params["photoUrl"].nil?)
      photo_report = PhotoReport.create!(user_id: @current_user.id, photo_url: params["photoUrl"])
    end

    existing_report = @current_user.daily_reports.where(date: params["date"])

    if (existing_report.count < 1)
      new_report = @current_user.daily_reports.create(date: params["date"],doing_okay: params["doingOkay"], medication_report: med_report, symptom_report: symptom_report)
      new_report.photo_report = photo_report
      new_report.save!
      render(json: new_report.as_json, status: 200)
    else
      old_report = existing_report.first
      old_report.update!(medication_report: med_report, doing_okay: params["doingOkay"], symptom_report: symptom_report, photo_report: photo_report, updated_at: DateTime.current)
      render(json: old_report.as_json, status: 200)
    end
  end

  def get_milestones
    response = @current_user.milestones.order(datetime: :desc)
    render(json: response.as_json, status: 200)
  end

  def update_notification_time
    if (@current_user.daily_notification.nil?)
      @current_user.create_daily_notification
    else
      @current_user.daily_notification.update_time(Time.parse(params["time"]))
    end

    obj = @current_user.daily_notification
    render(json: obj.as_json, status: 200)
  end

end
