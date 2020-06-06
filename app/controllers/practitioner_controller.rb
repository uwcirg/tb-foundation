require 'aws-sdk'
require 'securerandom'

class PractitionerController < UserController
    before_action :auth_practitioner, :except => [:upload_lab_test,:generate_presigned_url,:get_all_tests]

    def get_current_practitioner
      render(json: @current_practitoner.as_fhir_json, status: 200)
    end

    def generate_temp_patient

      #This generates a random 4 digit hex
      code = SecureRandom.hex(10).upcase[0,5]

      newTemp = TempAccount.create(
          phone_number: params[:phoneNumber],
          code_digest: BCrypt::Password.create(code),
          family_name: params[:familyName],
          given_name: params[:givenName],
          organization: params[:organization],
          treatment_start: params[:startDate],
          practitioner_id: @current_practitoner.id
        )

        if newTemp.save
          render(json: {account: newTemp.as_json, code: code}, status: 200)
        else
          @test = newTemp.errors.as_json
          @test = @test.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
          render(json: {error: 422, paramErrors: @test}, status: 422)
        end
    end

    def create_patient
        newPatient = Patient.create!(
        phone_number: params[:phoneNumber],
          password_digest: BCrypt::Password.create(params[:password]),
          family_name: params[:familyName],
          given_name: params[:givenName],
          managing_organization: params[:managingOrganization],
          treatment_start: params[:treatmentStart],
          type: "Patient"
        )
    
        render(json: newPatient.as_json, status: 200)
    end

    def get_patients

      #TODO Clean this up, there is duplicated code
      if (params.has_key?("namesOnly"))
        render(json: @current_practitoner.patient_names, status: 200)
        return
      end

      patients = Patient.where(practitioner_id: @current_practitoner.id)
      response = []
      patients.each do |patient| 
        response.push(patient.as_fhir_json)
    end


      render(json: response, status: 200)
    end

    def get_temp_accounts
      temp_accounts = TempAccount.all()
      response = []
      temp_accounts.each do |account| 
        response.push(account.as_fhir_json)
      end
      render(json: response,status: 200)
    end

    def generate_presigned_url

      s3 = Aws::S3::Resource.new
      bucket = s3.bucket('lab-strips')
      key = "lab-test-#{SecureRandom.uuid}.jpeg"
      obj = bucket.object(key)
      url = obj.presigned_url(:put)
        
        render json: {url: url, key: key}
    end

    def get_all_tests
      render( json: LabTest.all().as_json, status: 200)
    end

    def upload_lab_test

    newTest = LabTest.create!(
       test_id: params[:testId],
       description: params[:description],
       photo_url: params[:photoURL],
       is_positive: params[:isPositive],
       test_was_run: params[:testWasRun],
       minutes_since_test: params[:minutesSinceTest]
      )

      signer = Aws::S3::Presigner.new
      url = signer.presigned_url(:get_object, bucket: "lab-strips", key: newTest.photo_url)

      render(json: newTest.as_json, status: 200)
    end

    def get_photos
      photos = @current_practitoner.get_photos
      render(json: photos,status: 200)
    end

    def get_historical_photos
      photos = @current_practitoner.get_historical_photos
      render(json: photos,status: 200)
    end

    def audit_photo
      photo = PhotoReport.find(params[:photo_id])

      if(photo.nil?)
        render(json: {error: "That Photo Does Not Exist"}, status: 422 )
        return
      end

      if(params[:approved])
        photo.approve
      else(!params[:approved])
        photo.deny
      end

      render(json: {message: "Photo status updated"}, status: 200)
    
    end

    def send_notifcation_all
      Patient.all.map { |u| u.send_push_to_user("Please Take Your Medication","Click Here to Complete Report") }
      render(json: {message: "Success"}, status: 200)
    end


    def get_patient_reports
      patient = get_patient_by_id(params[:patient_id])

      if(patient.nil?)
        return
      end

      render(json: patient.proper_reports, status: 200)
    end

    def patients_with_symptoms
      #TODO - might be an inefficent query here
      #This way worked for the 7 day approach
      #severe = Patient.where(daily_reports: DailyReport.where(user_id: @current_practitoner.patients.select("id"), symptom_report: SymptomReport.has_symptom).last_week)
      patients = Patient.where(daily_reports: DailyReport.unresolved_symptoms)
      render(json: patients, status: 200)
    end

    def patients_missed_reporting

      #Old Way
      # list = []
      # @current_practitoner.patients.each do |patient|
      #   if(patient.has_missed_report)
      #     list.push(patient)
      #   end
      # end

      #Resolution.select('MAX(resolved_at), patient_id, resolved_at').group(:patient_id)

      #Number of reports since last resolution for each user

      list = Patient.where( id: @current_practitoner.test_func)


      render(json: list, status: 200)

      # reports_since_res = Patient.joins(:daily_reports,:resolutions).where("resolutions.kind": "MissedMedication").where("daily_reports.date > resolutions.updated_at").group("users.id").count("daily_reports.id")

      # list = []
      # render(json: reports_since_res,status: 200)
      # return
      # Resolution.where(patient: Practitioner.all.first.patients,kind: "MissedMedication").each do |res|
      #   good = ((DateTime.now - 1.day).to_date - res.updated_at.to_date).to_i
      #   puts(reports_since_res["#{res.patient_id}"])
      #   if(good - reports_since_res["#{res.patient_id}"] > 0)
      #     list.push(res.patient_id)
      #   end
      # end
      # render(json: list.as_json, status: 200)
    end

    def patients_with_adherence
      render(json: @current_practitoner.patients,status: 200)
    end

    def patient_symptom_summary
      render(json: @current_practitoner.patients.find(params["patient_id"]).symptom_summary, status: 200)
    end

    def recent_reports
      render(json: DailyReport.where(patient: @current_practitoner.patients).where("date > ?",(DateTime.now - 1.month).to_date).order( 'date DESC' ), status: 200)
    end

    def create_resolution

      case params["type"]

      when "symptom"
        resolution = @current_practitoner.patients.find(params["patient_id"]).resolve_symptoms
      when "medication"
        resolution = @current_practitoner.patients.find(params["patient_id"]).resolve_missing_report
      else
        render(json: {error: "#{params["type"]} is not a resolution type", status: 422})
      end


      render(json: resolution,status: 200)
    end

    private

    def get_patient_by_id(id)
      patient = Patient.find(id)
      
      #Practitioners should only be able to access their own patients
      if(patient.practitioner_id == @current_practitoner.id)
        return patient
      else
        render(json: {message: "Cannot access patients outside of your care"},status: 401)
        return nil
      end

    end


end