require 'aws-sdk'
require 'securerandom'

class PractitionerController < UserController
    before_action :auth_practitioner, :except => [:upload_lab_test,:generate_presigned_url,:get_all_tests]

    def auth_practitioner
        #Uses @decoded from User Controller(Super Class)
        id = @decoded[:user_id].to_i
        @current_practitoner = Practitioner.find(id)
    
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: "Practitioner Only Route" }, status: :unauthorized
    end

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
      test = @current_practitoner.get_photos
      render(json: test.as_json,status: 200)
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


end