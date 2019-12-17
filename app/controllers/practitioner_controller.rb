class PractitionerController < UserController
    before_action :auth_practitioner

    def auth_practitioner
        #Uses @decoded from User Controller(Super Class)
        id = @decoded[:user_id].to_i
        @current_user = Practitioner.find(id)
    
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: "Practitioner Only Route" }, status: :unauthorized
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

end