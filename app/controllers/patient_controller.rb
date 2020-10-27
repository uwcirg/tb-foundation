require "fileutils"
require "base64"

class PatientController < UserController
  before_action :auth_patient

  def get_patient
    render(json: @current_user, status: 200)
  end

  #Different from normal password change, doesnt require the exisiting password
  def change_inital_password

    #Verify that patient is in pending state, if they are not then they shouldnt be able to use this method
    if (@current_user.status != "Pending")
      render(json: { message: "Patient account already activated" }, status: 401)
      return
    end

    if (params[:password] == params[:passwordConfirmation])
      @current_user.update_password(params[:password])
      render(json: { message: "Password Upadate Success" }, status: 200)
    else
      render(json: { message: "password and passwordConfirmation do not match" }, status: 422)
    end
  end

  def activate_patient
    if (params[:enableNotifications] == true)
      @current_user.update_daily_notification(params[:notificationTime])
    end

    if (!@current_user.contact_tracing.nil?)
      @current_user.contact_tracing.update!(number_of_contacts: params[:numberContacts], contacts_tested: params[:contactsTested], patient_id: @current_user.id)
    else
      @current_user.contact_tracing = ContactTracing.create!(number_of_contacts: params[:numberContacts], contacts_tested: params[:contactsTested], patient_id: @current_user.id)
    end

    @current_user.update(gender: params[:gender], age: params[:age], status: "Active")
    @current_user.save!

    render(json: @current_user, status: 200)
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

  #@TODO move this code to new filepatients/daily_reports_controller.rb
  def post_daily_report
    med_report = MedicationReport.create!(date: params["date"], user_id: @current_user.id, medication_was_taken: params["medicationWasTaken"], datetime_taken: params["dateTimeTaken"], why_medication_not_taken: params["whyMedicationNotTaken"])
    symptom_report = SymptomReport.create!(date: params["date"], user_id: @current_user.id,
                                           nausea: params["nausea"],
                                           nausea_rating: params["nauseaRating"],
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
      photo_report = PhotoReport.create!(date: params["date"], user_id: @current_user.id, photo_url: params["photoUrl"])
    end

    if (!@current_user.has_reported_today(DateTime.parse(params["date"])))
      new_report = @current_user.daily_reports.create(date: params["date"], 
        created_offline: (params["createdOffline"] ? params["createdOffline"] : false),
        doing_okay: params["doingOkay"], 
        doing_okay_reason: params["doingOkayReason"], 
        medication_report: med_report, symptom_report: symptom_report)
      new_report.photo_report = photo_report
      new_report.save!
      render(json: new_report, status: 200)
    else
      report = @current_user.daily_reports.find_by(date: params["date"])
      report.update!(medication_report: med_report,created_offline: (params["createdOffline"] ? params["createdOffline"] : false), doing_okay: params["doingOkay"], symptom_report: symptom_report, photo_report: photo_report, updated_at: DateTime.current)
      render(json: report, status: 200)
    end
  end

  def get_milestones
    response = @current_user.milestones.order(datetime: :desc)
    render(json: response.as_json, status: 200)
  end

  def update_notification_time

    if(params[:enabled] == false)
       @current_user.daily_notification.destroy!
       response = {isoTime: nil,time:nil}
    else
      response = @current_user.update_daily_notification(Time.parse(params["time"])).as_json
    end

    render(json: response, status: 200)
  end



end
