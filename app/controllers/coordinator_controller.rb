require 'securerandom'

class CoordinatorController < AuthenticatedController
    skip_before_action :verify_authenticity_token
    before_action :auth_coordinator, except: [:generate_zip]

    def reset_password
        random_string = SecureRandom.hex[0,7];
        Participant.update(params["userID"],{password_digest:  BCrypt::Password.create(random_string)} )
        render(json: {new_password: random_string}, status: 200)
    end

    def get_current_coordinator
        render json: {name: @current_user.name, email: @current_user.email, uuid: @current_user.uuid} , status: :ok
    end

    def get_participant
        participant = Participant.find(params["userID"]);
        render json: participant.to_json, status: :ok
    end

    def generate_zip_url
        baseURL = ENV["URL_API"]
        token = JsonWebToken.encode({temp: "true"},5.minutes.from_now)
        url = "#{baseURL}/strip_zip_file?token=#{token}"
        render json: { url: url}, status: :ok
    end

    #In the future this will need to be mapped to coordinators for the multi-site study
    def get_records
        participant_records = Participant.all.map(&:summary)
        resolutions = Resolution.all.as_json
        render json: {participant_records: participant_records, resolutions: resolutions}, status: :ok
    end

    def resolve_records

        medication_reports = MedicationReport.where(id: params["medication_ids"])
        symptom_reports = SymptomReport.where(id: params["symptom_ids"])
        strip_reports = StripReport.where(id: params["strip_ids"])
        coordinator = Coordinator.find_by(uuid: params["coordinator_uuid"])

        resolution = Resolution.create!(
            participant_uuid: params["uuid"],
            status: params["status"],
            timestamp: params["timestamp"],
            note: params["note"],
            medication_reports: medication_reports,
            symptom_reports: symptom_reports,
            strip_reports: strip_reports,
            uuid: SecureRandom.uuid,
            author: coordinator
        )
        render json: resolution.to_json, status: :ok

    end

    def set_photo_status
        StripReport.find(params["userID"]).update(status: params["status"]);
        render json: {status: "photo status updated"}, status: :ok
    end

    def post_new_coordinator

        newCoordinator = Coordinator.new(
          name: params["name"],
          email: params["email"],
          password_digest:  BCrypt::Password.create(params["password"]),
          uuid: SecureRandom.uuid,
        )
    
        newCoordinator.save
    
        render(json: newCoordinator.to_json, status: 200)
      end

end
